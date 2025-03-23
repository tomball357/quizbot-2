class MessagesController < ApplicationController
  def index
    @list_of_messages = Message.order(created_at: :desc)
    render({ template: "messages/index" })
  end

  def show
    the_id = params.fetch("path_id")
    @the_message = Message.find_by(id: the_id)
    render({ template: "messages/show" })
  end

  def create
    the_message = Message.new(
      sim_id: params.fetch("query_sim_id"),
      body: params.fetch("query_body"),
      role: params.fetch("query_role", "user")
    )
  
    if the_message.valid?
      the_message.save
  
      message_list = the_message.sim.messages.order(:created_at).map do |msg|
        { "role" => msg.role, "content" => msg.body }
      end
  
      client = OpenAI::Client.new(access_token: ENV.fetch("OPENAI_API_KEY"))
  
      begin
        # Get AI text response
        api_response = client.chat(
          parameters: {
            model: ENV.fetch("OPENAI_MODEL"),
            messages: message_list
          }
        )
  
        # After getting assistant_text from OpenAI:
        assistant_text = api_response.dig("choices", 0, "message", "content")

        # Define stable story base (can extract dynamically from system message if needed)
        story_context = "A rebel officer named Zak stationed at Echo Base during a snowstorm on the ice planet Hoth."

        # Build dynamic scene prompt (basic version using full assistant reply)
        scene_description = assistant_text.truncate(150)
        image_prompt = "#{story_context} Scene: #{scene_description}"

        # Generate image
        image_response = client.images.generate(parameters: {
          prompt: image_prompt,
          n: 1,
          size: "512x512"
        })

        image_url = image_response.dig("data", 0, "url")

        # Save assistant message with image
        Message.create!(
          role: "assistant",
          sim_id: the_message.sim_id,
          body: assistant_text,
          image_url: image_url
        )

        redirect_to("/vbooks/#{the_message.sim_id}", notice: "Message and image generated.")
      rescue => e
        logger.error "OpenAI API error: #{e.message}"
        redirect_to("/vbooks/#{the_message.sim_id}", alert: "AI response failed. Please try again.") and return
      end
    else
      redirect_to("/vbooks/#{the_message.sim_id}", alert: the_message.errors.full_messages.to_sentence)
    end
  end
  

  def update
    the_message = Message.find_by(id: params.fetch("path_id"))
    the_message.sim_id = params.fetch("query_sim_id")
    the_message.body = params.fetch("query_body")
    the_message.role = params.fetch("query_role")

    if the_message.valid?
      the_message.save
      redirect_to("/messages/#{the_message.id}", notice: "Message updated successfully.")
    else
      redirect_to("/messages/#{the_message.id}", alert: the_message.errors.full_messages.to_sentence)
    end
  end

  def destroy
    the_message = Message.find_by(id: params.fetch("path_id"))
    the_message.destroy
    redirect_to("/messages", notice: "Message deleted successfully.")
  end
end

class MessagesController < ApplicationController
  def index
    matching_messages = Message.all

    @list_of_messages = matching_messages.order({ :created_at => :desc })

    render({ :template => "messages/index" })
  end

  def show
    the_id = params.fetch("path_id")

    matching_messages = Message.where({ :id => the_id })

    @the_message = matching_messages.at(0)

    render({ :template => "messages/show" })
  end

  def create
    the_message = Message.new
    the_message.sim_id = params.fetch("query_sim_id")
    the_message.body = params.fetch("query_body")
    the_message.role = "user"

    if the_message.valid?
      the_message.save

      # Get the next AI reply and save it

      message_list = []

      the_message.sim.messages.order(:created_at).each do |the_message|
        message_hash = {
          "role" => the_message.role,
          "content" => the_message.body
        }

        message_list.push(message_hash)
      end

      client = OpenAI::Client.new(access_token: ENV.fetch("OPENAI_API_KEY"))

      api_response = client.chat(
        parameters: {
          model: ENV.fetch("OPENAI_MODEL"),
          messages: message_list
        }
      )

      new_assistant_message = Message.new
      new_assistant_message.role = "assistant"
      new_assistant_message.sim_id = the_message.sim_id
      new_assistant_message.body = api_response.fetch("choices").at(0).fetch("message").fetch("content")
      new_assistant_message.save

      redirect_to("/vbooks/#{the_message.sim_id}", { :notice => "Message created successfully." })
    else
      redirect_to("/vbooks/#{the_message.sim_id}", { :alert => the_message.errors.full_messages.to_sentence })
    end
  end

  def update
    the_id = params.fetch("path_id")
    the_message = Message.where({ :id => the_id }).at(0)

    the_message.sim_id = params.fetch("query_sim_id")
    the_message.body = params.fetch("query_body")
    the_message.role = params.fetch("query_role")

    if the_message.valid?
      the_message.save
      redirect_to("/messages/#{the_message.id}", { :notice => "Message updated successfully."} )
    else
      redirect_to("/messages/#{the_message.id}", { :alert => the_message.errors.full_messages.to_sentence })
    end
  end

  def destroy
    the_id = params.fetch("path_id")
    the_message = Message.where({ :id => the_id }).at(0)

    the_message.destroy

    redirect_to("/messages", { :notice => "Message deleted successfully."} )
  end
end

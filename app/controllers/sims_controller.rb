class SimsController < ApplicationController
  def index
    matching_sims = Sim.all

    @list_of_sims = matching_sims.order({ :created_at => :desc })

    render({ :template => "vbooks/index" })
  end

  def show
    the_id = params.fetch("path_id")

    matching_sims = Sim.where({ :id => the_id })

    @the_sim = matching_sims.at(0)

    render({ :template => "vbooks/show" })
  end

  def create
    the_sim = Sim.new
    the_sim.topic = params.fetch("query_topic")

    if the_sim.valid?
      the_sim.save

      # Create system message

      system_message = Message.new
      system_message.sim_id = the_sim.id
      system_message.role = "system"
      system_message.body = "You are a virtual simulation guide for #{the_sim.topic}. Based on the full storyline of #{the_sim.topic}, including key plot points, characters, locations, you must create a simulation for the user where they are part of the story. Start with an easy question about how to navigate a key challenge in #{the_sim.topic}. After each answer, ask a new question with a few set options to continue to evolve the scenario and allow a new simulated storyline to unfold. Continue to ask new questions until the user asks for the simulation to end.

In the end, provide a unique scenario that the user must navigate."
      #system_message.save

      # Create first user message

      user_message = Message.new
      user_message.role = "user"
      user_message.sim_id = the_sim.id
      user_message.body = "Can I be immersed in the world of #{the_sim.topic}?"
      user_message.save

      # Call API to get first assistant message

      client = OpenAI::Client.new(access_token: ENV.fetch("OPENAI_API_KEY"))

      message_list = [
        {
          "role" => "system",
          "content" => "You are a virtual simulation guide for #{the_sim.topic}. Based on the full storyline of #{the_sim.topic}, including key plot points, characters, locations, you must create a simulation for the user where they are part of the story. Start with an easy question about how to navigate a key challenge in #{the_sim.topic}. After each answer, ask a new question with a few set options to continue to evolve the scenario and allow a new simulated storyline to unfold. Continue to ask new questions until the user asks for the simulation to end. 

In the end, provide a unique scenario that the user must navigate."
        },
        {
          "role" => "user",
          "content" => "Can I be immersed in the world of #{the_sim.topic}?"
        }
      ]

      api_response = client.chat(
        parameters: {
          model: ENV.fetch("OPENAI_MODEL"),
          messages: message_list
        }
      )

      assistant_content = api_response.fetch("choices").at(0).fetch("message").fetch("content")

      assistant_message = Message.new
      assistant_message.role = "assistant"
      assistant_message.sim_id = the_sim.id
      assistant_message.body = assistant_content
      assistant_message.save

      redirect_to("/vbooks/#{the_sim.id}", { :notice => "Simulation created successfully." })
    else
      redirect_to("/vbooks/#{the_sim.id}", { :alert => the_sim.errors.full_messages.to_sentence })
    end
  end

  def update
    the_id = params.fetch("path_id")
    the_sim = Sim.where({ :id => the_id }).at(0)

    the_sim.topic = params.fetch("query_topic")

    if the_sim.valid?
      the_sim.save
      redirect_to("/vbooks/#{the_sim.id}", { :notice => "Simulation updated successfully."} )
    else
      redirect_to("/vbooks/#{the_sim.id}", { :alert => the_sim.errors.full_messages.to_sentence })
    end
  end

  def destroy
    the_id = params.fetch("path_id")
    the_sim = Sim.where({ :id => the_id }).at(0)

    the_sim.destroy

    redirect_to("/vbooks", { :notice => "Simulation deleted successfully."} )
  end
end

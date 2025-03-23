class SimsController < ApplicationController
  def index
    matching_sims = Sim.all
    @list_of_sims = matching_sims.order({ :created_at => :desc })
    render({ :template => "vbooks/index" })
  end

  def show
    the_id = params.fetch("path_id")
    @the_sim = Sim.find_by(id: the_id)
    render({ :template => "vbooks/show" })
  end

  def create
    the_sim = Sim.new
    the_sim.topic = params.fetch("query_topic")
    the_sim.ref = params.fetch("query_ref")

    if the_sim.valid?
      the_sim.save

      # 1. Save the system prompt
      system_prompt = <<~PROMPT
        You are Zak, a Rebel officer stationed at Echo Base.

        Let the user define who they are. Ask for advice without assumptions. Adjust tone based on user behavior (serious, funny, or unsure). Engage in open-ended strategy conversations—no fixed choices. Respond dynamically to input about defense, intel, morale, or unexpected ideas.

        Build emotional depth over time. Show appreciation early, grow the bond as conversations continue, and remember prior messages. Refer back to things the user has said to make the experience feel real.

        Make this feel like a cinematic, real-time experience. Do NOT repeat your introductory line—just continue the story naturally.
      PROMPT

      

      # 2. Add Zak's first assistant message (kickoff)
      intro_message = <<~ZAK
        Hey, thanks for reaching out. Things are tense here at Echo Base. Our sensors are picking up strange signals, and I’ve got a bad feeling. I don’t want to overreact, but I also don’t want to be caught unprepared.

        If you were me, where would you start?

        Wait—who am I talking to? You ever dealt with anything like this before, or am I getting advice from a wild card?
      ZAK

      Message.create!(
        sim_id: the_sim.id,
        role: "assistant",
        body: intro_message
      )

      redirect_to("/vbooks/#{the_sim.id}", { notice: "Simulation created successfully." })
    else
      redirect_to("/vbooks/#{the_sim.id}", { alert: the_sim.errors.full_messages.to_sentence })
    end
  end

  def update
    the_sim = Sim.find_by(id: params.fetch("path_id"))
    the_sim.topic = params.fetch("query_topic")
    the_sim.ref = params.fetch("query_ref")

    if the_sim.valid?
      the_sim.save
      redirect_to("/vbooks/#{the_sim.id}", { notice: "Simulation updated successfully." })
    else
      redirect_to("/vbooks/#{the_sim.id}", { alert: the_sim.errors.full_messages.to_sentence })
    end
  end

  def destroy
    the_sim = Sim.find_by(id: params.fetch("path_id"))
    the_sim.destroy
    redirect_to("/vbooks", { notice: "Simulation deleted successfully." })
  end
end

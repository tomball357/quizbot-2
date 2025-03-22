Rails.application.routes.draw do
  # Routes for the Message resource:

  # CREATE
  post("/insert_message", { :controller => "messages", :action => "create" })
          
  # READ
  get("/messages", { :controller => "messages", :action => "index" })
  
  get("/messages/:path_id", { :controller => "messages", :action => "show" })
  
  # UPDATE
  
  post("/modify_message/:path_id", { :controller => "messages", :action => "update" })
  
  # DELETE
  get("/delete_message/:path_id", { :controller => "messages", :action => "destroy" })

  #------------------------------

  get("/", { :controller => "sims", :action => "index" })

  # Routes for the Vbook resource:

  # CREATE
  post("/insert_sim", { :controller => "sims", :action => "create" })
          
  # READ
  get("/vbooks", { :controller => "sims", :action => "index" })
  
  get("/vbooks/:path_id", { :controller => "sims", :action => "show" })
  
  # UPDATE
  
  post("/modify_sim/:path_id", { :controller => "sims", :action => "update" })
  
  # DELETE
  get("/delete_sim/:path_id", { :controller => "sims", :action => "destroy" })

  #------------------------------

  # This is a blank app! Pick your first screen, build out the RCAV, and go from there. E.g.:

  # get "/your_first_screen" => "pages#first"
  
end

class Main < Application
  @@cloud = nil

  # ...and remember, everything returned from an action
  # goes to the client...
  def index
    if @@cloud.nil?
      puts "TAAGGGGSSS BY MOST COMPOETELELELKJ!!!"
      @@cloud = Person.tags_by_most_complete
    end
    @cloud = @@cloud
    render
  end
  
end

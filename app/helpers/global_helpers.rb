module Merb
  module GlobalHelpers
    # helpers defined here available to all views.  
    def tag_cloud(people, classes)
      max, min = 0, 0
      people.each { |p|
        max = p.tag_score if p.tag_score > max
        min = p.tag_score if p.tag_score < min
      }

      divisor = ((max - min) / classes.size) + 1

      people.each { |p|
        yield p.full_name, classes[(p.tag_score - min) / divisor]
      }
    end
  end
end

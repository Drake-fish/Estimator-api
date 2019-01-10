require "thor"
require "json"
class Estimator < Thor

  desc "estimate time for a project PARAMS: Optimistic Time Estimate, Most Likely Time Estimate, Pessimistic Time Estimate", "estimate time"


  method_option :weighted, :type => :boolean, :aliases => :w
  method_option :short,    :type => :boolean, :aliases => :s
  method_option :json,     :type => :boolean, :aliases => :j

  def estimate(low, real, high)
    if validate_params?(low, real, high)
      values = options.dup.merge!({low: low, real: real, high: high})
      output(values)
    else
      STDERR.puts "Invalid input #{low} #{real} #{high} should all be numbers!"
    end
  end

  no_commands {
    def output(values)
        return message_output(weighted_json(values))  if values[:weighted] && values[:json]
        return message_output(weighted_short(values)) if values[:weighted] && values[:short]
        return message_output("Your weighted average estimated time is #{weighted(values)} and standard deviation is #{standard_deviation(values)}") if values[:weighted]
        return message_output(json(values)) if values[:json]
        return message_output(short(values)) if values[:short]
        return message_output("Your average estimated time is #{average(values)} and standard deviation is #{standard_deviation(values)}")
    end

    def weighted_json(values)
      {
       :average => weighted(values),
       :standardDeviation => standard_deviation(values),
       :optimisticTime => values[:low].to_i,
       :realisticTime => values[:real].to_i,
       :pessimisticTime => values[:high].to_i,
       :weighted => true
      }.to_json
    end

    def weighted(values)
      ((values[:low].to_f + values[:real].to_f * 4 + values[:high].to_f) / 6).round(2)
    end

    def weighted_short(values)
      "T: #{weighted(values)} SD: #{standard_deviation(values)}"
    end

    def short(values)
      "T #{average(values)} SD: #{standard_deviation(values)}"
    end

    def json(values)
      {
       :average => average(values),
       :standardDeviation => standard_deviation(values),
       :optimisticTime => values[:low].to_i,
       :realisticTime => values[:real].to_i,
       :pessimisticTime => values[:high].to_i,
       :weighted => false
      }.to_json
    end

    def average(values)
      ((values[:low].to_f + values[:real].to_f + values[:high].to_f) / 3).round(2)
    end

    def standard_deviation(values)
      ((values[:high].to_f - values[:low].to_f) /6).round(2)
    end

    def validate_params?(low, real, high)
      (is_i?(low)) && (is_i?(real)) && (is_i?(high))
    end

    def is_i?(val)
      /\A[-+]?\d+\z/ === val
    end

    def message_output(msg)
      puts msg
    end
  }

end

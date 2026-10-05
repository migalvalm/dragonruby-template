# Data files: DR.parse_json_file returns string keys, so this symbolizes them all the way down (values stay as they are).
module JsonFile
  def self.load path
    symbolize DR.parse_json_file(path)
  end

  def self.symbolize v
    case v
    when Hash then v.map { |k, x| [k.to_sym, symbolize(x)] }.to_h
    when Array then v.map { |x| symbolize(x) }
    else v
    end
  end
end

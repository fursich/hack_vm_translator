module Inflector
  def constantize(name, base: Object)
    base.const_get(camelize(name))
  end

  def camelize(name)
    name.to_s.split('/').map{ |part| to_camel(to_underscore(part)) }.join('::')
  end

  def underscore(name)
    name.to_s.split('::').map{ |part| to_underscore(to_camel(part)) }.join('/')
  end

  def to_underscore(part)
    part.gsub(/([^A-Z])([A-Z])/,'\1_\2').gsub(/-/, '_').downcase
  end

  def to_camel(part)
    part.to_s.split('_').map(&:capitalize).join
  end

  def last_name
    self.class.name.split('::').last
  end
end

module Wiki
	abstract class Template
		def self.process( text : String )
			replacements = [] of String
			finished = false
			while !finished
				finished = true
				text = text.gsub(/\{\{[^\{\}]+\}\}/) {|m|
					finished = false
					i = replacements.size
					replacements.push(parse_and_expand_instance(m,replacements))
					"%%#{i}%%"
				}
			end
			text = restore_replacements(text,replacements)
			text
		end
		def self.restore_replacements( text : String, replacements : Array(String) ) : String
			text.gsub(/%%([0-9])%%/) {|str,m|
				replacements[m[1].to_i32]
			}
		end
		def self.parse_and_expand_instance( text : String, replacements : Array(String) ) : String
			name,args = parse_instance(text)

			# Fill in the replacement values for nested templates, but only if needed
			if replacements.size > 0
				args.keys.each {|k|
					v = args[k]
					args[k] = restore_replacements(v,replacements)
				}
			end

			# TODO: get template for name
			template = Wiki::Template.from_name( name )
			#template = StringTemplate.new("{{{1}}}")

			return template.expand( args )
		end
		def self.parse_instance( text : String )
			parts = text.strip[2...-2].split("|")
			template_name = parts[0].strip

			args = {} of String|Int32 => String

			parts[1..-1].each_with_index {|part,idx|
				items = part.split("=")
				case items.size
					when 1
						args[idx] = items[0].strip
					when 2
						args[items[0].strip] = items[1].strip
					else
						raise "Syntax error"
				end
			}

			return {template_name,args}
		end

		abstract def expand( args : Hash(String|Int32,String) ) : String

		def self.from_name( name : String ) : Template
			if !(t=from_macro_name(name)).nil?
				return t
			end
			if File.exists?(filename="template/#{name}.md") 
				return StringTemplate.new( File.read(filename) )
			end
			raise "Unable to find template #{name}"
			#StringTemplate.new("{{{1}}}")
		end
		def self.from_macro_name( name : String ) : Template?
			nil
		end
	end

	class StringTemplate < Template
		def initialize( @text : String )
		end
		def expand( args : Hash(String|Int32,String) ) : String
			@text.gsub(/<noinclude>.*<\/noinclude>/m,"").
			gsub(/<!--.*?-->/m,"").
			gsub(/\{\{\{([0-9 |]+)\}\}\}/) {|text,m|
				default,key = if (k=m[1]).includes?("|")
					parts = k.split("|")
					{parts[1..-1].join("|"),parts[0].strip}
				else
					{"",m[1]}
				end
				args[ key.to_i32-1 ]? || default
			}.gsub(/\{\{\{([a-zA-Z0-9 \|]+)\}\}\}/) {|text,m|
				default,key = if (k=m[1]).includes?("|")
					parts = k.split("|")
					{parts[1..-1].join("|"),parts[0].strip}
				else
					{"",m[1]}
				end
				args[ key ]? || default
			}
		end
	end
end

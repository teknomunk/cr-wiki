class Wiki::Template::If < Wiki::Template
	NAME = "#if"

	def expand( args : Arguments )
		if (args[0]?||"").strip != ""
			args[1]? || ""
		else
			args[2]? || ""
		end
	end
end
class Wiki::Template::IfEq < Wiki::Template
	NAME = "#ifeq"

	def expand( args : Arguments )
		if( (args[0]?||"").strip == (args[1]?||"").strip )
			args[2]? || ""
		else
			args[3]? || ""
		end
	end
end
class Wiki::Template::Switch < Wiki::Template
	NAME = "#switch"

	def expand( args : Arguments )
		key = (args[0]?||"").strip

		if args.has_key?(key)
			args[key]
		elsif args.has_key?("#default")
			args["#default"]
		else
			""
		end
	end
end

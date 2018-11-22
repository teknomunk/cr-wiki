require "markd"

class Markd::HTMLRenderer
	def link( node : Node, entering : Bool )
		if entering
			href = node.data["destination"].as(String)
			if !href.includes?("://")
				if !( /\.html/ =~ href )
					href += ".html"
				end
			end
			attrs = attrs(node)
			if !(@options.safe && potentially_unsafe(href))
				attrs["href"] = escape(href)
			end

			if (title = node.data["title"].as(String)) && !title.empty?
				attrs["title"] = escape(title)
			end

			tag("a", attrs)
		else
			tag("/a")
		end
	end
end

module Wiki
	VERSION = "0.1.0"

	def self.generate_page( pagename : String )
		puts "Generating HTML for #{pagename}"
		text = File.open(pagename).gets_to_end
		text = Template.process(text)
		text = Markd.to_html(text)
		text = Layout.layout(text)
		File.open(pagename.gsub(/\.md$/,".html"),"w") {|f|
			f.puts(text)
		}
	end
	def self.generate_pages_in_directory( dir : Dir )
		puts "Generating pages for #{dir.path}"
		dir.each_child {|c|
			full_path = File.join(dir.path,c)
			if File.directory?(full_path)
				generate_pages_in_directory(Dir.new(full_path))
			elsif File.file?(full_path)
				generate_page(full_path)
			else
				puts "Unknown file type #{full_path}"
			end
		}
	end
	def self.generate_pages()
		generate_pages_in_directory(Dir.new("public/"))
	end
end

require "./wiki/*"

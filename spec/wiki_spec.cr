require "./spec_helper"

describe Wiki do
	it "handles templates" do
		Wiki::Template.process( <<-TEMPLATE
			{{spec/chembox
			| Name = Sodium sulfate
			| Identifiers Section = 
				{{spec/chembox identifiers
				|CAS Number= 1313-82-2<br/>1313-84-4</br>1313-84-4
				}}
			}}
			TEMPLATE
		).should eq(<<-RESULT
			
			<div style='float:right;width:30em'>
			<table>
			<tr><td>Identifiers</td></tr>
			<tr><td>CAS Number</td><td>1313-82-2<br/>1313-84-4</br>1313-84-4</td></tr>
			</table>
			</div>


			RESULT
		)
	end
	it "generates pages" do
		Wiki.generate_pages()
	end
end

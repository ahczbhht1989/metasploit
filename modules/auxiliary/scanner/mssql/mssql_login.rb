##
# $Id: mssql_login.rb 5880 2008-11-11 05:12:52Z hdm $
##

##
# This file is part of the Metasploit Framework and may be subject to 
# redistribution and commercial restrictions. Please see the Metasploit
# Framework web site for more information on licensing and terms of use.
# http://metasploit.com/projects/Framework/
##


require 'msf/core'


class Metasploit3 < Msf::Auxiliary
        
	include Msf::Exploit::Remote::MSSQL
	include Msf::Auxiliary::Scanner
	
	def initialize
		super(	
			'Name'           => 'MSSQL Login Utility',
			'Version'        => '$Revision: 5880 $',
			'Description'    => 'This module simply queries the MSSQL instance for a specific user/pass (default is sa with blank).',
			'Author'         => 'MC',
			'License'        => MSF_LICENSE
		)
	
		register_options(
			[
				OptString.new('MSSQL_USER', [ false, 'The username to authenticate as', 'sa']),
				OptString.new('MSSQL_PASS', [ false, 'The password for the specified username', '']),
				Opt::RPORT(1433)
			], self.class)
	end
		
	def run_host(ip)

		user = datastore['MSSQL_USER'].to_s
		pass = datastore['MSSQL_PASS'].to_s
		
		user = "sa" if user.length == 0
		
		begin
		info = mssql_login

		if (info == true)
			print_status("#{ip}:#{rport} successful logged in as '#{user}' with password '#{pass}'")
		else
			print_status("#{ip}:#{rport} failed to login as '#{user}'")
		end
		rescue ::Interrupt
			raise $!
		rescue ::Rex::ConnectionError
		end
	end	

end

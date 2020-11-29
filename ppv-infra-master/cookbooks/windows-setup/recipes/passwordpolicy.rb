powershell_script 'Set_Windows_Password_Complexity' do
  guard_interpreter :powershell_script
  code <<-EOH
    secedit /export /cfg c:\\secpol.cfg
	(gc C:\\secpol.cfg).replace(\"PasswordComplexity = 0\", \"PasswordComplexity = 1\") | Out-File C:\\secpol.cfg
	secedit /configure /db c:\\windows\\security\\local.sdb /cfg c:\\secpol.cfg /areas SECURITYPOLICY
	rm -force c:\\secpol.cfg -confirm:$false
    EOH
end

powershell_script 'Set_Windows_Password_Policy' do
  guard_interpreter :powershell_script
  code <<-EOH
    NET ACCOUNTS /MINPWLEN:14
    NET ACCOUNTS /UNIQUEPW:3
    EOH
end

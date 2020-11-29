['/usr/share/lua', '/usr/share/lua/5.1', '/usr/local/lib/lua', '/usr/local/lib/lua/5.1'].each do |lua_dir|
  directory lua_dir do
  end
end

# Coming from https://github.com/hamishforbes/lua-resty-iputils
template '/usr/share/lua/5.1/iputils.lua' do
   source 'lua_modules/iputils.lua'
end

# Coming from http://bitop.luajit.org/ LuaBitOp-1.0.2
# This module has been compilated with gcc and can not be moved in a other folder (otherwise it will not work !)
template '/usr/local/lib/lua/5.1/bit.so' do
   source 'lua_modules/bit.so'
end

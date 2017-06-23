
local function onLogin(fd, protTab)
	print("------onLogin--------", fd)
	if not protTab.loginName or not protTab.loginPwd then 
		return g_protocol.sendErrcode(fd, "M_LOGIN_ACC_OR_PWD_ERROR") 
	end
	local db = FGDBaccount.query(protTab.loginName)
    if not db or db:get("accountPwd")~=protTab.loginPwd then
        return g_protocol.sendErrcode(fd, "M_LOGIN_ACC_OR_PWD_ERROR")
    end
	--其他协议
	local userId = db:get("userId")
	print("------onLogin--------", fd, userId)
    g_gameuser.onLoginUser(fd, userId)
    
	--登录成功
	local rpTab = {}
	rpTab.loginIn = 1	 
	g_protocol.sendProt(fd, MID_Protocol_Login, ALogin_S2CSignIN, rpTab)
end

local function onRegister(fd, protTab)
	if not protTab.accName or not protTab.accPwd then 
		return g_protocol.sendErrcode(fd, "SYS_UNKNOW_ERROR") --系统错误
	end
	if string.len(protTab.accName)<6 or string.len(protTab.accPwd)<6 then
		return g_protocol.sendErrcode(fd, "M_REGISTER_LONGERR_ACC") --用户名或密码太短
	end
	local regFlag = 2 --已被注册
	if not FGDBaccount.exist(protTab.accName) then 
		regFlag = 1 --注册成功
		local userId = g_gameuser.onRegisterUser(protTab.accName)
		local db = FGDBaccount.insert(protTab.accName)
		db:set("accountPwd", protTab.accPwd)
		db:set("userId", userId)
		db:update()
	end
	local rpTab = {}
	rpTab.isSucces = regFlag
	g_protocol.sendProt(fd, MID_Protocol_Login, ALogin_S2CRegAccount, rpTab)
end


g_protocol.RegProtFunc(MID_Protocol_Login, ALogin_C2SSignIN, onLogin)
g_protocol.RegProtFunc(MID_Protocol_Login, ALogin_C2SRegAccount, onRegister)

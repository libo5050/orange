local API = {}
local table_insert = table.insert
local cjson = require("cjson")
local utils = require("orange.utils.utils")

API["/redirect/enable"] = {
    POST = function(store)
        return function(req, res, next)
            local enable = req.body.enable
            if enable == "1" then
                enable = true
            else
                enable = false
            end

            local current_redirect_config = store:get("redirect_config")
            current_redirect_config.enable = enable

            -- save to file
            store:set("redirect_config", current_redirect_config)
            local store_result = store:store()

            if store_result == true then
                res:json({
                    success = true,
                    msg = (enable == true and "开启redirect成功" or "关闭redirect成功")
                })
            else
                res:json({
                    success = false,
                    data = (enable == true and "开启redirect失败" or "关闭redirect失败")
                })
            end
        end
    end
}

API["/redirect/configs"] = {
    GET = function(store)
        return function(req, res, next)
            local result = {
                success = true,
                data = store:get("redirect_config")
            }

            res:json(result)
        end
    end,

    PUT = function(store)
        return function(req, res, next)
        	local rule = req.body.rule
        	rule = cjson.decode(rule)
            rule.id = utils.new_id()
        	-- check
        	local current_redirect_config = store:get("redirect_config")
        	table_insert(current_redirect_config.redirect_rules, rule)

        	-- save to file
            store:set("redirect_config", current_redirect_config)
            local store_result = store:store()

            if store_result == true then
                res:json({
                    success = true,
                    data = current_redirect_config
                })
            else
                res:json({
                    success = false
                })
            end
        end
    end,

    DELETE = function(store)
        return function(req, res, next)
            local rule_id = tostring(req.body.rule_id)
            if not rule_id or rule_id == "" then
                return res:json({
                    success = false,
                    msg = "error param: rule id shoule not be null."
                })
            end

            -- check
            local current_redirect_config = store:get("redirect_config")
            local old_rules = current_redirect_config.redirect_rules
            local new_rules = {}
            for i, v in ipairs(old_rules) do 
                if v.id ~= rule_id then
                    table_insert(new_rules, v)
                end
            end
            current_redirect_config.redirect_rules = new_rules

            -- save to file
            store:set("redirect_config", current_redirect_config)
            local store_result = store:store()

            if store_result == true then
                res:json({
                    success = true,
                    data = current_redirect_config
                })
            else
                current_redirect_config.redirect_rules = old_rules
                res:json({
                    success = false,
                    data = current_redirect_config
                })
            end
        end
    end,


    POST = function(store)
        return function(req, res, next)
            local rule = req.body.rule
            rule = cjson.decode(rule)
            -- check
            local current_redirect_config = store:get("redirect_config")
            local old_rules = current_redirect_config.redirect_rules
            local new_rules = {}
            for i, v in ipairs(old_rules) do 
                if v.id == rule.id then
                    table_insert(new_rules, rule)
                else
                    table_insert(new_rules, v)
                end
            end
            current_redirect_config.redirect_rules = new_rules

            -- save to file
            store:set("redirect_config", current_redirect_config)
            local store_result = store:store()

            if store_result == true then
                res:json({
                    success = true,
                    data = current_redirect_config
                })
            else
                current_redirect_config.redirect_rules = old_rules
                res:json({
                    success = false,
                    data = current_redirect_config
                })
            end
        end
    end
}


return API
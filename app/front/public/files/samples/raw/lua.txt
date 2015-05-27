local IO = require "kong.tools.io"
local utils = require "kong.tools.utils"
local cache = require "kong.tools.database_cache"
local stringy = require "stringy"
local constants = require "kong.constants"
local responses = require "kong.tools.responses"
local timestamp = require "kong.tools.timestamp"

-- Define the plugins to load here, in the appropriate order
local plugins = {}

local _M = {}

local function load_plugin_conf(api_id, consumer_id, plugin_name)
  local cache_key = cache.plugin_configuration_key(plugin_name, api_id, consumer_id)

  local plugin = cache.get_and_set(cache_key, function()
    local rows, err = dao.plugins_configurations:find_by_keys {
        api_id = api_id,
        consumer_id = consumer_id ~= nil and consumer_id or constants.DATABASE_NULL_ID,
        name = plugin_name
      }
      if err then
        return responses.send_HTTP_INTERNAL_SERVER_ERROR(err)
      end

      if #rows > 0 then
        return table.remove(rows, 1)
      else
        return { null = true }
      end
  end)

  if plugin and not plugin.null and plugin.enabled then
    return plugin
  else
    return nil
  end
end

local function init_plugins()
  configuration.plugins_available = configuration.plugins_available and configuration.plugins_available or {}

  print("Discovering used plugins. Please wait..")
  local db_plugins, err = dao.plugins_configurations:find_distinct()
  if err then
    error(err)
  end

  -- Checking that the plugins in the DB are also enabled
  for _, v in ipairs(db_plugins) do
    if not utils.table_contains(configuration.plugins_available, v) then
      error("You are using a plugin that has not been enabled in the configuration: "..v)
    end
  end

  local unsorted_plugins = {} -- It's a multivalue table: k1 = {v1, v2, v3}, k2 = {...}

  for _, v in ipairs(configuration.plugins_available) do
    local loaded, mod = utils.load_module_if_exists("kong.plugins."..v..".handler")
    if not loaded then
      error("The following plugin has been enabled in the configuration but is not installed on the system: "..v)
    else
      print("Loading plugin: "..v)
      local plugin_handler = mod()
      local priority = plugin_handler.PRIORITY and plugin_handler.PRIORITY or 0

      -- Add plugin to the right priority
      local list = unsorted_plugins[priority]
      if not list then list = {} end -- The list is required in case more plugins share the same priority level
      table.insert(list, {
        name = v,
        handler = plugin_handler
      })
      unsorted_plugins[priority] = list
    end
  end

  local result = {}

  -- Now construct the final ordered plugin list
  -- resolver is always the first plugin as it is the one retrieving any needed information
  table.insert(result, {
    resolver = true,
    name = "resolver",
    handler = require("kong.resolver.handler")()
  })

  -- Add the plugins in a sorted order
  for _, v in utils.sort_table_iter(unsorted_plugins, utils.sort.descending) do -- In descending order
    if v then
      for _, p in ipairs(v) do
        table.insert(result, p)
      end
    end
  end

  return result
end

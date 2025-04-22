-- source: https://stackoverflow.com/a/26367080
function table.copy(obj, seen)
  if type(obj) ~= 'table' then return obj end
  if seen and seen[obj] then return seen[obj] end
  local s = seen or {}
  local res = setmetatable({}, getmetatable(obj))
  s[obj] = res
  for k, v in pairs(obj) do res[table.copy(k, s)] = table.copy(v, s) end
  return res
end

function table.merge(target, source)
    for k,v in pairs(source) do
        target[k] = v;
    end

    return target;
end

function toString(notString)
    if type(notString) ~= "string" then
        notString = notString.toString()
    end
    return notString;
end

local _print = print;
print = function ( ... )
    local out = {};
    for i,v in ipairs({...}) do
        
        if type(v) == "table" then
            v = json.serialize(v)
        end

        table.insert(out, v);
        table.insert(out, " ");
    end

    _print(table.unpack(out));
end
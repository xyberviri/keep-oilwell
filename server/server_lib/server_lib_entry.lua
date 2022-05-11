function GetAllOilrigsFromDatabase(option)
     if option == 'update' then
     elseif option == 'init' then
          MySQL.Async.fetchAll('SELECT * FROM oilrig_position', {}, function(oilrigs)
               Oilrigs:initPhaseTwo(oilrigs)
          end)
     end
end

function GetSingleValueByHash(oilrig_hash)
     MySQL.Async.fetch('SELECT * FROM oilrig_position WHERE oilrig_hash = ?', { oilrig_hash }, function(res)

     end)
end

function GeneralInsert(options)
     local sqlQuery = 'INSERT INTO oilrig_position (citizenid,name,oilrig_hash,position,metadata,state) VALUES (?,?,?,?,?,?)'
     local QueryData = {
          options.citizenid,
          options.name,
          options.oilrig_hash,
          json.encode(options.position),
          json.encode(options.metadata),
          options.state
     }
     MySQL.Async.insert(sqlQuery, QueryData)
end

function GeneralUpdate(options)
     if options == nil then
          return
     end
     local sqlQuery = ''
     local QueryData = {}

     if options.type == 'metadata' then
          sqlQuery = 'UPDATE oilrig_position SET metadata = ? WHERE citizenid = ? AND oilrig_hash = ?'
          QueryData = {
               json.encode(options.metadata),
               options.citizenid,
               options.oilrig_hash
          }
     elseif options.type == 'name' then
          -- rename

     elseif options.type == 'state' then
          -- toggle on/off

     elseif options.type == 'position' then
          -- rotate or change position

     end
     if sqlQuery == nil or next(QueryData) == nil then
          return false
     end
     MySQL.Async.execute(sqlQuery, QueryData, function(e)
     end)
end

function isTableChanged(oldTable, newTable)
     if equals(oldTable, newTable, true) == false then
          return true
     else
          return false
     end
end

function equals(o1, o2, ignore_mt)
     if o1 == o2 then return true end
     local o1Type = type(o1)
     local o2Type = type(o2)
     if o1Type ~= o2Type then return false end
     if o1Type ~= 'table' then return false end

     if not ignore_mt then
          local mt1 = getmetatable(o1)
          if mt1 and mt1.__eq then
               --compare using built in method
               return o1 == o2
          end
     end

     local keySet = {}

     for key1, value1 in pairs(o1) do
          local value2 = o2[key1]
          if value2 == nil or equals(value1, value2, ignore_mt) == false then
               return false
          end
          keySet[key1] = true
     end

     for key2, _ in pairs(o2) do
          if not keySet[key2] then return false end
     end
     return true
end

function deepcopy(orig, copies)
     copies = copies or {}
     local orig_type = type(orig)
     local copy
     if orig_type == 'table' then
          if copies[orig] then
               copy = copies[orig]
          else
               copy = {}
               copies[orig] = copy
               for orig_key, orig_value in next, orig, nil do
                    copy[deepcopy(orig_key, copies)] = deepcopy(orig_value, copies)
               end
               setmetatable(copy, deepcopy(getmetatable(orig), copies))
          end
     else -- number, string, boolean, etc
          copy = orig
     end
     return copy
end

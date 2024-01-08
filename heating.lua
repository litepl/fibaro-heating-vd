local device                 = fibaro:getSelfId();
local dataRoomTemp           = {};
local dataRoomTempSensor     = {};
local dataRoomThermostatTemp = {};
local dataRoomThermostat     = {};
local roomsToHeat            = {};

fibaro:debug('Heating loop started...');

for i = 1,1000 do
  local devType = fibaro:getType(i)
  --fibaro:debug(devType)

  local roomId = 0;

  if devType == "com.fibaro.thermostatDanfoss" then
    roomId                         = fibaro:getRoomID(i);
    roomSet                        = fibaro:getValue(i, "value");
    dataRoomThermostat[roomId]     = i;
    dataRoomThermostatTemp[roomId] = roomSet;
    fibaro: debug('Thermostat in ' .. roomId .. ' named ' .. fibaro:getName(i) .. ' set up to: ' .. roomSet);
  end

  if devType == "virtual_device" then
    if string.find(fibaro:getName(i), "VThermostat") then
      roomId                         = fibaro:getRoomID(i);
      roomSet                        = fibaro:getValue(i, "ui.Temperature.value");
      dataRoomThermostat[roomId]     = i;
      dataRoomThermostatTemp[roomId] = roomSet;
      fibaro:debug('Virtual thermostat in ' .. roomId .. ' named ' .. fibaro:getName(i) .. ' set up to: ' .. roomSet);
    end
  end

  if devType == "com.fibaro.temperatureSensor" then
    if string.find(fibaro:getName(i), '2', 1, true) == nil then
      roomId                     = fibaro:getRoomID(i);
      roomTemp                   = fibaro:getValue(i, "value");
      dataRoomTempSensor[roomId] = i;
      dataRoomTemp[roomId]       = roomTemp;
      fibaro:debug('Temperature ' .. fibaro:getName(i) .. ' in room ID ' .. roomId .. ' - ' .. roomTemp);
    end
  end
end

local hist = 0; -- no histeresis by default
local co_status = tonumber(fibaro:getGlobalValue('CO_STATUS'));

if co_status == 1 then
  hist = tonumber(fibaro:getGlobalValue('CO_SET_HIST'));
  fibaro:debug('Hysteresis: ' .. hist);
end

local roomRequiredTemp = 18; -- being set just in case of..,
local roomCurrentTemp  = 18; -- being set just in case of..,
local co_seton         = 0;
local roomName;

for k, v in pairs(dataRoomThermostatTemp) do
    roomRequiredTemp = v + hist;
    roomCurrentTemp  = tonumber(dataRoomTemp[k]);
    co_status        = tonumber(fibaro:getGlobalValue('CO_STATUS'));
    roomName         = fibaro:getRoomName(k);
    fibaro:debug('Room ' .. roomName .. ' Required(' .. dataRoomThermostat[k] .. ') ' .. roomRequiredTemp .. ' Current(' .. dataRoomTempSensor[k] .. ') ' .. roomCurrentTemp .. ' CO Status ' .. co_status);

  if roomCurrentTemp < roomRequiredTemp and co_status == 1 then
    co_seton = 1;
    table.insert(roomsToHeat, roomName);
    fibaro:debug('Still On');
  elseif roomCurrentTemp < roomRequiredTemp and co_status == 0 then
    co_seton = 1;
    table.insert(roomsToHeat, roomName);
    fibaro:debug('Turn On');
    end
end

if tonumber(fibaro:getGlobalValue('SUMMER')) == 1 then
    fibaro:debug('Summer time!');
    co_seton = 0;
end

if co_seton == 1 then
  fibaro:debug('Should be set On');
  fibaro:setGlobal('CO_STATUS', 1);
elseif co_seton == 0 then
  fibaro:debug('Turn Off');
  fibaro:setGlobal('CO_STATUS', 0);
end

co_status = tonumber(fibaro:getGlobalValue('CO_STATUS'));
fibaro:debug('New CO status ' .. co_status);

if co_status == 1 then
  fibaro:call(device, "setProperty", "ui.LabelStatus.value", "On");
  fibaro:call(device, "setProperty", "ui.LabelRoomsToHeat.value", table.concat(roomsToHeat, ", "));
elseif co_status == 0 then
  fibaro:call(device, "setProperty", "ui.LabelStatus.value", "Off");
  fibaro:call(device, "setProperty", "ui.LabelRoomsToHeat.value", "NONE");
end

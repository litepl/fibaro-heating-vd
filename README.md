## Description

Code finds all Danfoss thermostats (also virtual) and rooms' temparatures and compares them with hysteresis. If in any room temperature < thermostat value, heating is set to ON.

## Prepation

Set variables in HC panel:

| Variable | Description |
|----------|-------------|
| CO_STATUS | Will be set according to the code's result |
| CO_SET_HIST | Hysteresis value |
| SUMMER | Sets summertime. If value = 1, CO_STATUS is ALWAYS set to 0 (off) |

## Custmize to be used with different thermostats

Uncomment 

```
 --fibaro:debug(devType)
```

to check your thermostat device type

and change

```
com.fibaro.thermostatDanfoss
```

to the new value.

## What next?

Create a scenes like for ex.:

If CO_STATUS == 1 than turn on: 
 - heater power source relay
 - additional pump power source relay
 - heating triggering relay

If CO_STATUS == 0 than turn off: 
 - heating triggering relay
 - additional pump power source relay
 - heater power source relay

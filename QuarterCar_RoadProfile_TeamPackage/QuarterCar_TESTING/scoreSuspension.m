function result = scoreSuspension(simOut, roadName, cfg)

logs = simOut.logsout;

bodyAcceleration = logs.get("bodyAcceleration").Values.Data;
suspensionTravel = logs.get("suspensionTravel").Values.Data;
tireDeflection = logs.get("tireDeflection").Values.Data;

result.RoadName = string(roadName);

result.RMSAcceleration = rms(bodyAcceleration);
result.PeakAcceleration = max(abs(bodyAcceleration));
result.MaxSuspensionTravel = max(abs(suspensionTravel));
result.MaxTireDeflection = max(abs(tireDeflection));

result.ComfortPass = result.RMSAcceleration <= cfg.maxRMSAcceleration;
result.TravelPass = result.MaxSuspensionTravel <= cfg.maxSuspensionTravel;
result.RoadHoldingPass = result.MaxTireDeflection <= cfg.maxTireDeflection;

result.OverallPass = result.ComfortPass && ...
    result.TravelPass && result.RoadHoldingPass;

comfortScore = result.RMSAcceleration / cfg.maxRMSAcceleration;
travelScore = result.MaxSuspensionTravel / cfg.maxSuspensionTravel;
tireScore = result.MaxTireDeflection / cfg.maxTireDeflection;

result.Score = 0.5*comfortScore + 0.25*travelScore + 0.25*tireScore;

end

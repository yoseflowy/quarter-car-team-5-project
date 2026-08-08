function cfg = qcConfig()

cfg.modelName = "quarter_car_tire";

cfg.roadNames = ["speedbump","pothole","roughroad","ramp","curvedramp"];
cfg.speed = 15;

cfg.maxRMSAcceleration = 2.0;
cfg.maxSuspensionTravel = 0.10;
cfg.maxTireDeflection = 0.05;

end

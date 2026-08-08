function summaryTable = runAllTests()

cfg = qcConfig();

results = struct([]);

for i = 1:length(cfg.roadNames)

    roadName = cfg.roadNames(i);

    fprintf("Running %s (%d/%d)...\n", ...
        roadName, i, length(cfg.roadNames));

    [roadInput,~,~,~] = roadInputForTire(roadName, cfg.speed);

    assignin("base","roadInput",roadInput);

    simOut = sim(cfg.modelName);

    currentResult = scoreSuspension(simOut, roadName, cfg);

    if i == 1
        results = repmat(currentResult, length(cfg.roadNames), 1);
    end

    results(i) = currentResult;
end

summaryTable = struct2table(results);

disp(summaryTable);

if ~isfolder("results")
    mkdir("results");
end

writetable(summaryTable, "results/summaryTable.csv");

figure;
bar(categorical(summaryTable.RoadName), summaryTable.Score);
xlabel("Road");
ylabel("Score");
title("Suspension Test Results");
grid on;

saveas(gcf, "results/summaryFigure.png");

end

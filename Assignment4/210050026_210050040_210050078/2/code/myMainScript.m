tic;
clear; clc;

train_set = [];
test_set = [];
train_identity = [];
test_identity = [];

for i = 1:32
    d = dir("./ORL/s" + num2str(i) + "/*.pgm");
    for j = 1:length(d)
        img = double(imread(d(j).folder + "/" + d(j).name))/255; 
        if j <= 6
            train_set = [train_set img(:)];
            train_identity = [train_identity i];
        else
            test_set = [test_set img(:)];
            test_identity = [test_identity i];
        end
    end
end

% adding other people's faces in the test set also
% which should be classified as with no matching identity
for i = 33:40
    d = dir("./ORL/s" + num2str(i) + "/*.pgm");
    for j = 7:length(d)
        img = double(imread(d(j).folder + "/" + d(j).name))/255; 
        test_set = [test_set img(:)];
        test_identity = [test_identity i];
        % We gave identity of "i" to these people
        % Then, afterwards, we used the condition that
        % whoever's identity is >= 33 is the unknown person
    end
end

test_dim = size(test_set);
train_dim = size(train_set);

x_mean = mean(train_set, 2);
X = train_set - x_mean;
test_centered = test_set - x_mean;

% using eigs
L = (X.')*X;
[W, D] = eigs(L, train_dim(2));
V = X*W;

dim = size(V);
for i = 1:dim(2)
    V(:,i) = V(:,i)./norm(V(:,i));
end

unseen = [];
seen = [];
k = 50;         % Using k = 50
threshold = linspace(60,180,320);
best_tp = 0;
best_tn = 0;
best_fp = 0;
best_fn = 0;
accuracy = 0;
specificity = 0;
precision = 0;
f1_score = 0;
recall = 0;
V_k = V(:, 1:k);
alpha_l = (V_k')*X;
alpha_p = (V_k')*test_centered;
best_threshold = 0;

for th = 1:length(threshold)
    tp = 0;
    tn = 0;
    fp = 0;
    fn = 0;
    thresh = threshold(th);
    for p = 1:test_dim(2)
        diff = sum((alpha_l - alpha_p(:,p)).^2);
        [min_val, min_ind] = min(diff);
        if th == 1
            if test_identity(p) >= 33
                unseen = [unseen min_val];
            else
                seen = [seen min_val];
            end
        end
        if min_val > thresh
            if test_identity(p) >= 33
                tn = tn + 1;
            else
                fn = fn + 1;
            end
        else
            if test_identity(p) >= 33
                fp = fp + 1;
            else
                tp = tp + 1;
            end
         end
    end
    acc = (tp+tn)/(tp+tn+fp+fn);
    prec = tp/(tp+fp);
    rec = tp/(tp+fn);
    spec = tn/(tn+fp);
    f1 = 2*(prec*rec)/(prec + rec);
    if f1 > f1_score            % this can be changed to 
        accuracy = acc;         % fp == fn , for point 3 of report, and
        precision = prec;       % spec >= specificity, for point 2 of report        
        specificity = spec;     % Overall, we think that point 3's threshold
        recall = rec;           % is best for a general purpose case
        f1_score = f1;
        best_threshold = thresh;
        best_fn = fn;
        best_fp = fp;
        best_tn = tn;
        best_tp = tp;
    end
end
fprintf("Threshold Found : %f\n", best_threshold);
fprintf("Accuracy : %f\n", accuracy);
fprintf("Precision : %f\n", precision);
fprintf("Recall : %f\n", recall);
fprintf("Specificity : %f\n", specificity);
fprintf("F1 Score : %f\n", f1_score);
fprintf("False Positive : %f\n", best_fp);
fprintf("False Negative : %f\n", best_fn);
fprintf("True Positive : %f\n", best_tp);
fprintf("True Negative : %f\n", best_tn);

figure(1);
plot(seen, 'b', 'DisplayName', 'In training set');
hold on;
plot(unseen, 'r', 'DisplayName', 'Not In training set');
xlabel('Plotted at k = 50')
ylabel('Minimum squared difference');
legend;
title('Min. sq. differences for seen vs unseen data');
saveas(figure(1),"min_squared_differences", "png");
hold off;

toc;
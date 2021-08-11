function r = initiateCells(numberOfPoints,minAllowableDistance)

x1 = -3.5 + (3.5+3.5)*rand(1000000,1);
y1 = -3.5 + (3.5+3.5)*rand(1000000,1);
%minAllowableDistance = 0.4;
%numberOfPoints = 225;

% Initialize first point.
X = x1(1);
Y = y1(1);

% Try dropping down more points.
counter = 2;
k = 2;

while counter <= numberOfPoints
    % Get a trial point.
    thisX = x1(k);
    thisY = y1(k);
    % See how far is is away from existing keeper points.
    distances = sqrt((thisX-X).^2 + (thisY - Y).^2);
    minDistance = min(distances);
    if minDistance >= minAllowableDistance
        X(counter) = thisX;
        Y(counter) = thisY;
        counter = counter + 1;
    end
    k = k +1;
end

r = [X;Y]';

end


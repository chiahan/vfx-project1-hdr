function weight = weightingFunction(weightType)
    weight = zeros(256, 1);

    switch weightType
	case 'one'
	    weight = ones(256, 1);
	case 'debevec97'
	    weight = [0:1:255];
	    weight = min(weight, 255-weight);
    end
end

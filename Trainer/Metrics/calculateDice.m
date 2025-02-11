function diceCoeff = calculateDice(trueMask, predictedMask)
    assert(isequal(size(trueMask), size(predictedMask)), 'Masks must be the same size');

    % Ensure the inputs are binary masks
    trueMask = logical(trueMask);
    predictedMask = logical(predictedMask);

    diceCoeff = dice(trueMask, predictedMask);
end
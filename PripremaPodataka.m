numCols = width(belex); 

if numCols == 12
    belex(:, (numCols-2):numCols) = [];
end
belex = rmmissing(belex, 'DataVariables', {'Cena', 'Max', 'Min', 'Promena', 'Obim'});


velicina = size(belex.DatumTrgovanja);
velicina = velicina(1,1);


n = 5;

inputs = zeros(9, velicina);
targets = zeros(2, velicina);

closing_price = belex.Cena;
percentage_change = belex.Promena;
open_price = belex.Open;
high_price = belex.Max;
low_price = belex.Min;
volume = belex.Obim;

lowest_low_in_10days = zeros(1,velicina);
highest_high_in_10days = zeros(1,velicina);

if any(isnan(closing_price)) || any(isnan(high_price)) || any(isnan(low_price)) || any(isnan(volume))
    error('Ulazni podaci sadrže NaN vrednosti. Proverite i očistite podatke pre nego što nastavite.');
end

Mt = (closing_price+high_price+low_price)/3;
ADL = zeros(1, length(closing_price));

for i = 1:velicina-10
    % 4. Stochastic K%
    LL10 = min(low_price(i+1:i+10));
    HH10 = max(high_price(i+1:i+10));

    inputs(4,i) = (closing_price(i+1) - LL10)/(HH10-LL10) * 100;
end

for i = 1:velicina-10
    targets(1, i) = min(low_price(i+1:i+5));
    targets(2, i) = max(high_price(i+1:i+5));

    % 1. Simple 10-day moving average
    inputs(1,i) = mean(closing_price(i+1:i+10));

    % 2. Weighted 10-day moving average
    sum_of_weights = sum(1:10);
    weighted_sum = 0;
    for j = 1:10
        if isnan(closing_price(i+j))
            continue;
        end
        weighted_sum = weighted_sum + ((10-j+1) * closing_price(i+j));
    end
    inputs(2,i) = weighted_sum / sum_of_weights;

    % 3. Momentum
    inputs(3,i) = closing_price(i+1) - closing_price(i+10);
    if isnan(inputs(3,i))
        inputs(3,i) = 0;
    end
    
    % 5. Stochastic D%
    if i+10 <= velicina-10
        inputs(5,i) = mean(inputs(4,i+1:i+10));
    else
        inputs(5,i) = NaN;
    end
    
    % 6. RSI
    if i+10 <= velicina-10
        gains = max(diff(closing_price(i:i+10)), 0);
        losses = -min(diff(closing_price(i:i+10)), 0);
        avg_gain = mean(gains);
        avg_loss = mean(losses);
        if avg_loss == 0
            rs = Inf;
        else
            rs = avg_gain / avg_loss;
        end
        inputs(6,i) = 100 - (100 / (1 + rs));
    else
        inputs(6,i) = NaN;
    end

    % 7. CCI
    SMt = sum(Mt(i+1:i+10));
    for j=1:10
        inputs(7,i) = inputs(7,i) + abs(Mt(i+j)-SMt);
    end

    % 8. Larry William's
    inputs(8,i) = ((max(high_price(i+1:i+10)) - closing_price(i+1))/(max(high_price(i+1:i+10))-min(low_price(i+1:i+10))))*100;
    
    
    % 9. A/D
    if i>2
        if high_price(i+1) ~= low_price(i+1)
            CLV = ((closing_price(i+1) - low_price(i+1)) - (high_price(i+1) - closing_price(i+1))) / (high_price(i+1) - low_price(i+1));
            ADL(i) = ADL(i-1) + (CLV * volume(i));
            inputs(9,i) = ADL(i);
        else
            CLV = 0;
            ADL(i) = ADL(i-1) + (CLV * volume(i));
            inputs(9,i) = ADL(i);
        end
    end

end
%[inputs, inputSettings] = mapminmax(inputs);
%[targets, targetSettings] = mapminmax(targets);



%Funkcija koja racuna vrednost ulaza za mrezu na osnovu prethodnih 10 dana
function podaci_za_model = racunanje(closing_p, percentage_change, open_price, hp, lp, v, b,inputs,adl)

    model_inputs = zeros(9, 1);

    % 1
    model_inputs(1) = mean(closing_p(1:10));

    % 2
    sum_of_weights = sum(1:10);
    weighted_sum = 0;
    for j = 1:10
        if isnan(closing_p(j))
            continue;
        end
        weighted_sum = weighted_sum + ((10 - j + 1) * closing_p(j));
    end
    model_inputs(2) = weighted_sum / sum_of_weights;

    % 3
    model_inputs(3) = closing_p(1) - closing_p(10);

    % 4
    LL = min(lp(1:10));
    HH = max(hp(1:10));
    model_inputs(4) = (closing_p(1) - LL) / (HH - LL) * 100;

    % 5
    K = inputs(4,:);
    s = sum(K(1:9)) + model_inputs(4);
    model_inputs(5) = s/10;

    % 6
    gains = max(diff(closing_p(1:10)), 0);
    losses = -min(diff(closing_p(1:10)), 0);
    avg_gain = mean(gains);
    avg_loss = mean(losses);
    if avg_loss == 0
        rs = Inf; 
    else
        rs = avg_gain / avg_loss;
    end
    model_inputs(6) = 100 - (100 / (1 + rs));

    mt = (closing_p+hp+lp)/3;
    smt = sum(mt(1:10));
    
    for i=1:10
        model_inputs(7) = model_inputs(7) + abs(mt(i)-smt);
    end

    % 8.
    model_inputs(8) = ((max(hp(1:10)) - closing_p(1))/(max(hp(1:10))-min(lp(1:10))))*100;
    
    adl_array = zeros(10,1);
    adl_array(1) = adl;

    for i=2:10
        if hp(i) ~= lp(i)
            clv = ((closing_p(i) - lp(i)) - (hp(i) - closing_p(i))) / (hp(i) - lp(i));
            adl_array(i) = adl_array(i-1) + (clv * v(i));
            model_inputs(9) = adl_array(i);
        else
            clv = 0; 
            adl_array(i) = adl_array(i-1) + (clv * v(i));
            model_inputs(9) = adl_array(i);
        end
    end

    podaci_za_model = model_inputs;

end


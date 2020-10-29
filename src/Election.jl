module Election
    using DataFrames
    using CSV
    using Query
    
    export state_toplines, ev_by_state, combined
    
    state_toplines() = CSV.read("./data/presidential_state_toplines_2020.csv")
    ev_by_state() = CSV.read("./data/ev_by_state.csv")

    function combined()
        evs = ev_by_state()
        states = state_toplines()
        
        states |> 
        @join(  
          evs, _.state, _.state, 
          {_.modeldate, _.state, _.winstate_inc, __.evs}
         ) |> 
         DataFrame
    end
    
    function evs_for_state(state)
        if rand() < state.winstate_inc 
            state.evs 
        else 
            0 
        end
    end
    
    function simulate(states)
        evs = evs_for_state.(states)
        if sum(evs) >= 269 
            :trump
        else
            :biden
        end
    end
    
    function simulate_many(states, n)
        biden_or_trump = [simulate(states) for x in 1:n]
        trump_count = length(filter(x -> x == :trump, biden_or_trump))
        trump_count / n
    end
    
    function simulate_election_by_date(e)
        e |> 
        @groupby(_.modeldate) |> 
        @map({date=key(_), trump=simulate_many(_, 1000)}) |> 
        DataFrame
    end
end # module

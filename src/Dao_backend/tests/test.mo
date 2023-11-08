    public shared ({ caller }) func showVotes(id : Nat) : async [Principal] {
        let proposal = await getProposal(id);
        switch (proposal) {
            case (?proposal) {
                return proposal.voters;
            };
            case (null) {
                [caller];
            };
        };
    };

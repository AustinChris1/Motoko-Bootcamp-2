import Bool "mo:base/Bool";
import Nat "mo:base/Nat";
import Text "mo:base/Text";
import Int "mo:base/Int";
import Principal "mo:base/Principal";
import TrieMap "mo:base/TrieMap";
import Hash "mo:base/Hash";
import Result "mo:base/Result";
import Debug "mo:base/Debug";
import Array "mo:base/Array";
import level2 "canister:level2";
import level3 "canister:level3";
actor {

    type Status = {
        #Open;
        #Accepted;
        #Rejected;
    };

    type Proposal = {
        id : Nat;
        status : Status;
        manifest : Text;
        votes : Int;
        voters : [Principal];
    };

    type CreateProposalOk = {
        #ProposalCreated : Nat;
    };

    type CreateProposalErr = {
        #NotDAOMember;
        #NotEnoughTokens;

    };

    type VoteErr = {
        #ProposalNotFound;
        #AlreadyVoted;
        #ProposalEnded;
    };

    type VoteOk = {
        #ProposalAccepted;
        #ProposalRefused;
        #ProposalOpen;
    };

    type VoteResult = Result.Result<VoteOk, VoteErr>;

    type CreateProposalResult = Result.Result<CreateProposalOk, CreateProposalErr>;

    let proposals = TrieMap.TrieMap<Nat, Proposal>(Nat.equal, Hash.hash);

    var nextProposalId : Nat = 0;

    // Intercanister calls
    // token canister call

    public shared ({ caller }) func createProposal(m : Text) : async CreateProposalResult {
        //check if user is member
        let member = await level2.getMember(caller);
        switch (member) {
            case (#err(_)) return #err(#NotDAOMember);
            case (#ok(member)) {

                // check for enough tokens
                let account : level3.Account = {
                    owner = caller;
                    subaccount = null;
                };
                let balance = await level3.balanceOf(account);
                if (balance < 1) return #err(#NotEnoughTokens);
                nextProposalId += 1;
                let newProposal : Proposal = {
                    id = nextProposalId;
                    status = #Open;
                    manifest = m;
                    votes = 0;
                    voters = [];
                };
                proposals.put(nextProposalId, newProposal);
                Debug.print(debug_show (newProposal.voters));
                return #ok(#ProposalCreated(nextProposalId));

            };
        };

    };

    public shared query func getProposal(id : Nat) : async ?Proposal {
        proposals.get(id);
    };

    public shared ({ caller }) func vote(id : Nat, vote : Bool) : async VoteResult {
        let p = await getProposal(id);
        switch (p) {
            case (?p) {
                var voters = p.voters;
                var status = p.status;
                var newVotes = p.votes;

                let hasVoted = Array.find<Principal>(voters, func voter = voter == caller);
                switch (hasVoted) {
                    case (?hasVoted) return #err(#AlreadyVoted);
                    case (null) {
                        switch (status) {
                            case (#Open) {
                                let voteArray = Array.append<Principal>(voters, [caller]);
                                if (vote) {
                                    newVotes += 1;
                                } else {
                                    newVotes -= 1;
                                };

                                if (newVotes >= 100) {
                                    var status = #Accepted;
                                    return #ok(#ProposalAccepted);
                                };
                                if (newVotes <= -100) {
                                    var status = #Rejected;
                                    return #ok(#ProposalRefused);
                                };

                                let updatedProposal : Proposal = {
                                    id = p.id;
                                    status = status;
                                    manifest = p.manifest;
                                    votes = newVotes;
                                    voters = voteArray;

                                };
                                proposals.put(id, updatedProposal);

                                proposals.put(id, updatedProposal);
                                return #ok(#ProposalAccepted);
                            };
                            case (#Rejected) return #err(#ProposalEnded);
                            case (#Accepted) return #err(#ProposalEnded);
                        };
                    };
                };
            };
            case (null) return #err(#ProposalNotFound);
        };
    };

};

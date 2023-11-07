import Bool "mo:base/Bool";
import Nat "mo:base/Nat";
import Text "mo:base/Text";
import Int "mo:base/Int";
import Principal "mo:base/Principal";
import TrieMap "mo:base/TrieMap";
import Hash "mo:base/Hash";
import Result "mo:base/Result";
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


    public shared ({caller}) func createProposal(m : Text) : async CreateProposalResult {
        nextProposalId += 1;
        var newProposal : Proposal = {
            id = nextProposalId;
            status = #Open;
            manifest = m;
            votes = 0;
            voters = [];
        };
        let hasEnoughTokens = true;
        let isDaoMember = true;
        if (isDaoMember == false) return #err(#NotDAOMember);
        if (hasEnoughTokens == false) return #err(#NotEnoughTokens);
       
            proposals.put(nextProposalId, newProposal);
            return #ok(#ProposalCreated(nextProposalId));
        

    };

    public shared func getProposal(id : Nat) : async ?Proposal {
        if(proposals.get(id)) {
            return proposals.get(id);
        } else {
            return null;
        };
    };

    public shared ({caller}) func vote(id : Nat, vote: Bool) : async VoteResult {
        if(proposals.get(id)) {
            let proposal = proposals.get(id);
            if (proposal.status == #Open) {
                if (proposal.voters.contains(caller)) {
                    return #err(#AlreadyVoted);
                } else {
                    proposal.voters.put(caller);
                    proposal.votes += 1;
                    if (proposal.votes >= 2) {
                        proposal.status = #Accepted;
                        return #ok(#ProposalAccepted);
                    } else {
                        return #ok(#ProposalOpen);
                    };
                };
            } else {
                return #err(#ProposalEnded);
            };
        } else {
            return #err(#ProposalNotFound);
        };
    };

};

import HashMap "mo:base/HashMap";
import Principal "mo:base/Principal";
import Result "mo:base/Result";
import Nat "mo:base/Nat";
import Iter "mo:base/Iter";
import Text "mo:base/Text";

actor Level2 {

    type Member = {
        name : Text;
        age : Nat;
    };

    var member = HashMap.HashMap<Principal, Member>(1, Principal.equal, Principal.hash);

    public shared ({ caller }) func addMember(m : Member) : async Result.Result<(), Text> {
        var check = member.get(caller);
        switch (check) {
            case (?check) {
                return #err("User is already a member");
            };
            case (null) {
                member.put(caller, m);
                return #ok();
            };
        };
    };

    public shared ({ caller }) func updateMember(m : Member) : async Result.Result<(), Text> {
        var check = member.get(caller);
        switch (check) {
            case (?check) {
                member.put(caller, m);
                return #ok();
            };
            case (null) {
                return #err("User is not a member");
            };
        };
    };

    public shared query func getMember(p : Principal) : async Result.Result<Member, Text> {
        var check = member.get(p);
        switch (check) {
            case (?check) {
                return #ok(check);
            };
            case (null) {
                return #err("User is not a member");
            };
        };
    };

    public shared query func getAllMembers() : async [Member] {
        var allMembers = Iter.toArray<Member>(member.vals());
        return allMembers;
    };

    public shared query func numberOfMembers() : async Nat {
        member.size();
    };

    public shared ({ caller }) func removeMember(p : Principal) : async Result.Result<(), Text> {
        var check = member.get(caller);
        switch (check) {
            case (?check) {
                ignore member.remove(p);
                return #ok();
            };
            case (null) {
                return #err("User is not a member");
            };
        };
    };

};

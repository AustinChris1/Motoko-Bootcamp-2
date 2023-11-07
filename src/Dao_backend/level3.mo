import Blob "mo:base/Blob";
import Nat "mo:base/Nat";
import Hash "mo:base/Hash";
import Text "mo:base/Text";
import Principal "mo:base/Principal";
import TrieMap "mo:base/TrieMap";
import Result "mo:base/Result";
import Option "mo:base/Option";
import Account "Extras/account";

actor {

    type Account = Account.Account;
    
    var ledger = TrieMap.TrieMap<Account.Account, Nat>(Account.accountsEqual, Account.accountsHash);
    var supply : Nat = 0;

    public shared query func name() : async Text {
        let name = "Austenite";
        return name;
    };

    public shared query func symbol() : async Text {
        let symbol = "AUS";
        return symbol;
    };

    public shared func mint(p : Principal, n : Nat) : async Result.Result<(), Text> {
        let account : Account = {
            owner = p;
            subaccount = null;
        };
        let currentValue = Option.get(ledger.get(account), 0);
        let amount = currentValue + n;
        ledger.put(account, amount);
        return #ok();
    };

    public shared func balanceOf(account : Account) : async Nat {
        let bal : ?Nat = ledger.get(account);
        switch bal {
            case (null) return 0;
            case (?bal) return bal;
        };
    };

    public shared func transfer(from : Account, to : Account, amount : Nat) : async Result.Result<(), Text> {

        let balFrom = await balanceOf(from);
        if (balFrom < amount) {
            return #err("Insufficient Funds");
        } else {
            let balTo = await balanceOf(to);
            ledger.put(from, balFrom - amount);
            ledger.put(to, balTo + amount);
            return #ok();
        };

    };

    public shared func totalSupply() : async Nat {
        for ((key, value) in ledger.entries()) {
            supply += value;
        };
        return supply;
    };

};

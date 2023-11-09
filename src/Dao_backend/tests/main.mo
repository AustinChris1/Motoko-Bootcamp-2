import Dao_backend "canister:Dao_backend";
import Text "mo:base/Text";
actor {
    public query func all() : async Text {
        let _name : Text = Dao_backend.getName();
        let _manifesto : Text = Dao_backend.getManifesto();
        let _goals : [Text] = Dao_backend.getGoals();
        var all : Text = _name # " " # _manifesto;

    };
};

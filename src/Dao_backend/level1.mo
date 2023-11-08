import Text "mo:base/Text";
import Buffer "mo:base/Buffer";
actor Level1{
  
  let name : Text = "Austin's DAO";
  var manifesto : Text = "Funding of Decentralized Projects";

  var goals = Buffer.Buffer<Text>(10);

  public shared query func getName() : async Text {
    return name;
  };

  public shared query func getManifesto() : async Text {
    return manifesto;
  };

  public shared func setManifesto(m : Text) : async (){
    manifesto := m;
    return ();
  };

  public shared func addGoal(goal : Text) : async (){
    goals.add(goal);
    return ();
  };

  public shared query func getGoals() : async [Text] {
    var allGoals = Buffer.toArray(goals);
    return allGoals;
  };

};

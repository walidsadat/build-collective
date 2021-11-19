pragma solidity >=0.4.22 <0.9.0;
pragma experimental ABIEncoderV2;

import "./Ownable.sol";

contract BuildCollective is Ownable {
  struct User {
    string username;
    uint256 balance;
    bool registered;
  }

  address[] public userAddresses;

  struct Entreprise {
    string name;
    address owner;
    address[] membersAddresses;
    uint256 balance;
  }

  uint256 internal ProjectId;

  struct Project {
    uint256 id;
    string name;
    uint256 balance;
    address[] contributorsAddresses;
    address owner;
    string belongsTo; // "User" or "Entreprise"
    string link; //Link to GitHub or GitLab project
  }

  uint256 internal BountieId;

  struct Bountie {
    uint256 id;
    uint256 reward;
    address opener;
    address payable solver;
    string link; //Link to GitHub or GitLab issue
    bool solved;
  }

  mapping(address => User) private users;
  mapping(address => Entreprise) private entreprises;
  mapping(address => Project[]) private projects;
  mapping(uint => Bountie[]) private bounties;

  event UserSignedUp(address indexed userAddress, User indexed user);
  event EntrepriseSignedUp(address indexed ownerAddress, Entrepreise indexed entreprise);
  event ProjectCreated(address indexed ownerAddress, Project indexed project);
  event BountieOpened(address indexed openerAddress, Bountie indexed bountie);

  //User 
  function getAllUsers() external view returns (address[] memory){
    return userAddresses;
  }

  function addBalance(uint256 amount) public returns (bool) {
    require(users[msg.sender].registered);
    users[msg.sender].balance += amount;
    return true;
  }

  function user(address userAddress) public view returns (User memory) {
    require(users[userAddress].registred);
    return users[userAddress];
  }

  function signUp(string memory username, uint256 amount) public returns (User memory) {
    require(bytes(username).length > 0);
    users[msg.sender] = User(username, amount, true);
    emit UserSignedUp(msg.sender, users[msg.sender]);
    userAddresses.push(msg.sender);
    return users[msg.sender];
  }

  //Entreprise
  function entreprise(address entrepriseAddress) public view returns (Entreprise memory) {
    return entreprises[entrepriseAddress];
  }

  function signUpEntreprise(string memory entreprisename, address[] memory members, uint256 balance) public returns (Entreprise memory) {
    require(users[msg.sender].registred);
    require(bytes(entreprisename).length > 0);
    entreprisenames[msg.sender] = Entreprise(entreprisename, msg.sender, members, balance);
    emit EntrepriseSignedUp(msg.sender, entreprises[msg.sender]);
    return entrerpises[msg.sender];
  }

  function addBalanceEntreprise(uint256 amount) public returns (bool) {
    require(entreprises[msg.sender].registered);
    entreprises[msg.sender].balance += amount;
    return true;
  }

  //Project
  function getProjectsByAddress(address ownerAddress) public view returns (Project[] memory){
    require(users[ownerAddress].registered);
    return projects[ownerAddress];
  }

  function getProjectByIdAndAddress(address ownerAddress, uint256 id) public view returns (Project memory) {
    require(users[ownerAddress].registered);
    Project[] memory ownerProjects = getProjectsByAddress(ownerAddress);
    for (uint i = 0; i < ownerProjects.length; i++){
      if (ownerProjects[i].id == id){
        return ownerProjects[i];
      }
    }
    return ownerProjects[0];
  }

  function createProject(string memory name, uint256 memory balance, string memory belongsTo, address[] memory contributorsAddresses, string memory link) public returns (Project memory){
    require(users[msg.sender].registred);
    require(bytes(name).length > 0);
    ProjectId++;
    Project memory project = Project(ProjectId, name, balance, contributorsAddresses, msg.sender, belongsTo, link);
    projects[msg.sender].push(project);
    emit ProjectCreated(msg.sender, project);
    return project;
  }

  function sponsorProject(address ownerAddress, uint256 projectId, uint256 amount) public returns (bool){
    require(users[ownerAddress].registered);
    for(uint i = 0; i < projects[ownerAddress].length; i++){
      if(projects[ownerAddress][i].id == projectId){
        users[msg.sender].balance -= amount;
        projects[ownerAddress][i].balance += amount;
        return true;
      }
    }
    return false;
  }

  //Bountie
  function getBountiesByProjectId(uint256 projectId) public view returns (Bountie[] memory) {
    require(projectId <= ProjectId);
    return bounties[projectId];
  }

  function openBountie(uint256 projectId, uint256 reward, string memory link) public returns (Bountie memory){
    require (users[msg.sender].registred);
    BountieId++;
    Bountie memory bountie = Bountie(BountieId, reward, msg.sender, address(0), link, false);
    bounties[projectId].push(bountie);
    emit BountieOpened(msg.sender, bountie);
    return bountie;
  }

  function closeBountie(uint256 projectId, uint256 bountieId, address payable solver) public returns (bool){
    for(uint i = 0; i < bounties[projectId].length; i++){
      if(bounties[projectId][i].id == bountieId){
        require(!bounties[projectId][i].solver);
        bounties[projectId][i].solved = true;
        bounties[projectId][i].solver = solver;
        return fixer.send(bounties[projectId][i].reward);
      }
    }
    return false;
  }
}

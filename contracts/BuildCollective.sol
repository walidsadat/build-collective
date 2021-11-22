pragma solidity >=0.4.22 <0.9.0;
pragma experimental ABIEncoderV2;

import "./Ownable.sol";

contract BuildCollective is Ownable {

  //Structs
  struct User {
    string username;
    uint256 balance;
    bool registered;
  }

  address[] internal usersAddresses;

  struct Entreprise {
    string name;
    address owner;
    address[] members;
    uint256 balance;
  }

  uint256 internal CptProject;

  struct Project {
    uint256 id;
    string name;
    address owner;
    address[] contributors;
    uint256 balance;
    bool belongsToUser;
    string link;
  }

  uint256 internal CptBountie;

  struct Bountie {
    uint256 id;
    address opener;
    address payable solver;
    string link;
    uint256 reward;
    bool resolved;
  }

  mapping(address => User) private users;
  mapping(address => Entreprise) private entreprises;
  mapping(address => Project[]) private projects;
  mapping(uint => Bountie[]) private bounties;

  event UserSignedUp(address indexed userAddress, User indexed user);
  event EntrepriseSignedUp(address indexed ownerAddress, Entreprise indexed entreprise);
  event ProjectCreated(address indexed ownerAddress, Project indexed project);
  event BountieOpened(address indexed openerAddress, Bountie indexed issue);

  //User
  function allUsers() external view returns (address[] memory) {
    return usersAddresses;
  }

  function user(address userAddress) public view returns (User memory) {
    return users[userAddress];
  }

  function signUp(string memory username) public returns (User memory) {
    require(bytes(username).length > 0);
    users[msg.sender] = User(username, 0, true);
    usersAddresses.push(msg.sender);
    emit UserSignedUp(msg.sender, users[msg.sender]);
    return users[msg.sender];
  }

  function addBalance(uint256 amount) public returns (bool) {
    require(users[msg.sender].registered);
    users[msg.sender].balance += amount;
    return true;
  }

  //Entreprise
  function entreprise(address entrepriseAddress) public view returns (Entreprise memory) {
    require(users[msg.sender].registered);
    return entreprises[entrepriseAddress];
  }

  function signUpEntreprise(string memory name, address[] memory members, uint256 balance) public returns (Entreprise memory) {
    require(users[msg.sender].registered);
    require(bytes(name).length > 0);
    entreprises[msg.sender] = Entreprise(name, msg.sender, members, balance);
    emit EntrepriseSignedUp(msg.sender, entreprises[msg.sender]);
    return entreprises[msg.sender];
  }

  //Project
  function getProjects(address owner) public view returns (Project[] memory){
    return projects[owner];
  }

  function getProjectById(address owner, uint256 id) public view returns (Project memory) {
    Project[] memory projects = getProjects(owner);
    for (uint i = 0; i < projects.length; i++){
      if (projects[i].id == id){
        return projects[i];
      }
    }
    return projects[0];
  }

  function createProject(string memory name, address[] memory contributors, uint256 balance, bool belongsToUser, string memory link) public returns (Project memory){
    require(users[msg.sender].registered);
    require(bytes(name).length > 0);
    CptProject++;
    Project memory project = Project(CptProject, name, msg.sender, contributors, balance, belongsToUser, link);
    projects[msg.sender].push(project);
    emit ProjectCreated(msg.sender, project);
    return project;
  }

  function sponsorProject(address owner, uint256 projectId, uint256 amount) public returns (bool){
    require(users[owner].registered);
    for(uint i = 0; i < projects[owner].length; i++){
      if(projects[owner][i].id == projectId){
        users[msg.sender].balance -= amount;
        projects[owner][i].balance += amount;
        return true;
      }
    }
    return false;
  }

  //Bountie
  function getProjectBounties(uint256 id) public view returns (Bountie[] memory) {
    return bounties[id];
  }

  function openBountie(address projectOwner, uint256 projectId, string memory link, uint256 reward) public returns (Bountie memory){
    require(users[projectOwner].registered);
    require(users[msg.sender].registered);
    CptBountie++;
    Bountie memory bountie = Bountie(CptBountie, msg.sender, address(0), link, reward, false);
    bounties[projectId].push(bountie);
    emit BountieOpened(msg.sender, bountie);
    return bountie;
  }

  function closeBountie(uint256 projectId, uint256 bountieId, address payable solver) public payable returns (bool){
    for (uint i = 0; i < bounties[projectId].length; i++){
      if (bounties[projectId][i].id == bountieId) {
        bounties[projectId][i].resolved = true;
        bounties[projectId][i].solver = solver;
        return solver.send(bounties[projectId][i].reward);
      }
    }
    return false;
  }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract UserRegistry {
    struct User {
        string login;
        string password;
        bool exists;
    }

    mapping(address => User) private users;

    event UserRegistered(address user, string login, string password);
    event UserUpdated(address user, string login, string password);

    function registerUser(string memory _login, string memory _password) public {
        require(!users[msg.sender].exists, "User already registered.");

        users[msg.sender] = User({
            login: _login,
            password: _password,
            exists: true
        });

        emit UserRegistered(msg.sender, _login, _password);
    }

    function getUser(address _user) public view returns (string memory _login, string memory _password) {
        require(users[_user].exists, "User not found.");
        User memory user = users[_user];
        return (user.login, user.password);
    }

    function updateUser(string memory _login, string memory _password) public {
        require(users[msg.sender].exists, "User not registered.");

        users[msg.sender].login = _login;
        users[msg.sender].password = _password;
        

        emit UserUpdated(msg.sender, _login, _password);
    }
}

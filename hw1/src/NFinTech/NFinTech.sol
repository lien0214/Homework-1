// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC721 {
    function balanceOf(address owner) external view returns (uint256 balance);
    function ownerOf(uint256 tokenId) external view returns (address owner);
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;
    function safeTransferFrom(address from, address to, uint256 tokenId) external;
    function transferFrom(address from, address to, uint256 tokenId) external;
    function approve(address to, uint256 tokenId) external;
    function setApprovalForAll(address operator, bool approved) external;
    function getApproved(uint256 tokenId) external view returns (address operator);
    function isApprovedForAll(address owner, address operator) external view returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);
}

interface IERC721TokenReceiver {
    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data)
        external
        returns (bytes4);
}

contract NFinTech is IERC721 {
    string private _name;
    string private _symbol;

    uint256 private _tokenId;

    mapping(uint256 => address) private _owner;
    mapping(address => uint256) private _balances;
    mapping(uint256 => address) private _tokenApproval;
    mapping(address => bool) private isClaim;
    mapping(address => mapping(address => bool)) _operatorApproval;

    error ZeroAddress();

    constructor(string memory name_, string memory symbol_) payable {
        _name = name_;
        _symbol = symbol_;
    }

    function claim() public {
        if (isClaim[msg.sender] == false) {
            uint256 id = _tokenId;
            _owner[id] = msg.sender;

            _balances[msg.sender] += 1;
            isClaim[msg.sender] = true;

            _tokenId += 1;
        }
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function balanceOf(address owner) public view returns (uint256) {
        if (owner == address(0)) revert ZeroAddress();
        return _balances[owner];
    }

    function ownerOf(uint256 tokenId) public view returns (address) {
        address owner = _owner[tokenId];
        if (owner == address(0)) revert ZeroAddress();
        return owner;
    }

	error InvalidAddress();

	function setApprovalForAll(address operator, bool approved) external override {
		if (operator == address(0)) revert InvalidAddress();

		_operatorApproval[msg.sender][operator] = approved;
		emit ApprovalForAll(msg.sender, operator, approved);
	}

	function isApprovedForAll(address owner, address operator) public view override returns (bool) {
		return _operatorApproval[owner][operator];
	}

	function approve(address to, uint256 tokenId) public override {
		address owner = _owner[tokenId];
		require(msg.sender == owner || isApprovedForAll(owner, msg.sender),
			"ERC721: approve caller is not owner nor approved for all");

		_tokenApproval[tokenId] = to;
		emit Approval(owner, to, tokenId);
	}

	function getApproved(uint256 tokenId) public view override returns (address) {
		require(_owner[tokenId] != address(0), "ERC721: approved query for nonexistent token");
		return _tokenApproval[tokenId];
	}

	function transferFrom(address from, address to, uint256 tokenId) public override {
		// The caller must be allowed to transfer this token
		require(_isApprovedOrOwner(msg.sender, tokenId), "NFinTech: transfer caller is not owner nor approved");

		// Addresses must be valid
		require(from != address(0), "NFinTech: transfer from the zero address");
		require(to != address(0), "NFinTech: transfer to the zero address");

		// Clear approvals from the previous owner
		_approve(address(0), tokenId);

		// Update balances
		_balances[from] -= 1;
		_balances[to] += 1;

		// Transfer ownership
		_owner[tokenId] = to;

		// Emit the transfer event
		emit Transfer(from, to, tokenId);
	}

	function safeTransferFrom(address from, address to, uint256 tokenId) public override {
		safeTransferFrom(from, to, tokenId, "");
	}

	function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory _data) public override {
		require(_isApprovedOrOwner(msg.sender, tokenId), "ERC721: transfer caller is not owner nor approved");
		_safeTransfer(from, to, tokenId, _data);
	}

	function _isApprovedOrOwner(address spender, uint256 tokenId) private view returns (bool) {
		require(_owner[tokenId] != address(0), "NFinTech: operator query for nonexistent token");
		address owner = ownerOf(tokenId);
		return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
	}

	// Make sure to implement the _approve function if not already done
	function _approve(address to, uint256 tokenId) private {
		_tokenApproval[tokenId] = to;
		emit Approval(ownerOf(tokenId), to, tokenId);
	}

	function _transfer(address from, address to, uint256 tokenId) private {
		require(ownerOf(tokenId) == from, "ERC721: transfer of token that is not own");
		require(to != address(0), "ERC721: transfer to the zero address");

		// Clear approvals
		_approve(address(0), tokenId);

		_balances[from] -= 1;
		_balances[to] += 1;
		_owner[tokenId] = to;

		emit Transfer(from, to, tokenId);
	}

	function _safeTransfer(address from, address to, uint256 tokenId, bytes memory _data) private {
		_transfer(from, to, tokenId);
		require(_checkOnERC721Received(from, to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
	}

	function _checkOnERC721Received(address from, address to, uint256 tokenId, bytes memory _data) private returns (bool) {
		if (to.code.length > 0) { // Check if `to` is a contract
			try IERC721TokenReceiver(to).onERC721Received(msg.sender, from, tokenId, _data) returns (bytes4 retval) {
				return retval == IERC721TokenReceiver.onERC721Received.selector;
			} catch (bytes memory reason) {
				if (reason.length == 0) {
					revert("ERC721: transfer to non ERC721Receiver implementer");
				} else {
					/// @solidity memory-safe-assembly
					assembly {
						revert(add(32, reason), mload(reason))
					}
				}
			}
		} else {
			return true; // If `to` is not a contract, no need to check
		}
	}

}

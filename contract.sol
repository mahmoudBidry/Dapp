// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract wolfNFT is ERC721, ERC721Enumerable, ERC721URIStorage, Ownable {
    
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter;

    uint256 public mintPrice;
    uint256 public maxSupply;
    uint256 public maxPerWallet;
    uint256 public minQuantity;
    string public link;
    

    constructor() payable ERC721("wolfNFT", "WNFT"){
        mintPrice = 0.005 ether;
        maxSupply = 100;
        maxPerWallet = 3;
        minQuantity = 1;
        link = "https://gateway.pinata.cloud/ipfs/QmaXdVYjGRscsa87CBk16CsRpZqpkBWH2BeSsKG5xsiAru/";
    }
    
    function safeMint(address to, uint256 quantity) public payable {
        require(quantity >= minQuantity && quantity <= maxPerWallet, "the quantity must be between 1 and 3");
        require(msg.value >= mintPrice * quantity,"Not enough funds");
        require(totalSupply() + quantity <= maxSupply,"Max supply exceeded");
        require(balanceOf(msg.sender) + quantity <= maxPerWallet, "Number of nft per wallet exceeded");
        

        for(uint256 i =0; i<quantity; i++){
             _tokenIdCounter.increment();
            uint256 tokenId = _tokenIdCounter.current();
            string memory uri = string(abi.encodePacked(link, Strings.toString(totalSupply()+1), ".json"));
            _safeMint(to, tokenId);
            _setTokenURI(tokenId, uri);
        }        
    }

    function balanceOf(address _owner) public override view returns (uint256) {
        return ERC721.balanceOf(_owner);
    }

    function withdraw() public onlyOwner{
        require(address(this).balance > 0, "Balance is 0");
        payable(owner()).transfer(address(this).balance);
    }
    
    function transferFrom(address _from, address _to, uint256 _tokenId) public  override {
        require(_exists(_tokenId), "Token doesn't exist");
        require(ownerOf(_tokenId) == _from, "not owner");
        require(msg.sender == _from, "you are not the owner");
        _transfer(_from, _to, _tokenId);
    }

    // ERC721Enumerable

    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal override(ERC721, ERC721Enumerable){
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function supportsInterface(bytes4 interfaceId) public view override(ERC721, ERC721Enumerable) returns (bool){
        return super.supportsInterface(interfaceId);
    }

    // override ERC721URIStoragea
    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }
    function tokenURI(uint256 tokenId) public view override(ERC721, ERC721URIStorage) returns (string memory)
    {
        return super.tokenURI(tokenId);
    }
}
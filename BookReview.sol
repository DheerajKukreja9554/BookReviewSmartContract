// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/*STRUCTURE

*ASSUMING THAT THE ONE WHO DEPLOYS THE CONTRACT IS A PUBLIHER OF THE BOOK WHO WANTS THE REVIEW 
*HE PROVIDES THE LINK OF THE BOOK , DEADLINE TO WRITE THE REVIEWS AND INVESTS SOME AMAOUT AND HOW MUCH TO BE GIVEN TO ONE REVIEWER
*THE REVIWER GETS THE LINK AND COMES AFTER READING IT AND SUBMITTING HIS REVIEWS
*A MECHANISM WHICH CHECKS HIS REVIEW FOR VALIDATIOM(WHICH I TEND TO IMPROVE)
*AFTER THIS HE GETS HIS REWARD

*/
struct reviewer_status{
    uint timestamp;//TIME WHEN HE GOT THE LINK
    uint paystatus;//CHECKS IF HE IS PAID OR NOT
    uint validreview;//to check if review is valid or not
}

contract BookReview{
    
    int counter=0;//CHECKS WHETHER THIS SMART CONTARCT IS ACTIVATED OR NOT//ACTIVATES WHEN PUBLISHER ENTERS THE LINK
    uint each;//AMOUT GIVEN TO EACH REVIEW
    string link;//LINK OF THE BOOK
    
    mapping(address =>reviewer_status ) reviewer_address;//STORES TJE ADDRESS OF MARKED REVIEWERS AND THERE INFO
    
    //guide for publisher
    function for_publisher() external pure returns(string memory){
        
        string memory publisher_guide= "IN ACTIVATE FUNCTION\nPROVIDE LINK FOR YOUR BOOK\nINVEST SOME WEI\nCONTRACT ENDS WHEN THIS INVESTMENT IS FINISHED\nAND AMOUT OF WEI GIVEN TO EACH REVIEWER\nYOU CAN CHECK THE ACTIVATION OF CONTARCT IN checkActivation FUNCTION";
        
        return publisher_guide;
    }
    //guide for REVIEWER 
    function for_reviewer() external pure returns (string memory){
        
        string memory reviewer_guide= "IN markEntry FUNCTION\nPROVIDE YOUR ADDRESS \nINVEST SOME 100 WEI(INCASE YOU SUBMIT WRONG REVIEW)\nCOLLECT LINK IN getlink FUNCTION\nCOME AFTER 2 DAYS AND SUBMIT YOUR REVIEW IN SUBMIT FUNCTION AND IF IT VALIDATES GET YOUR REWARD IN COLLECT FUNCTION \nREVIEW SHOOULD BE ATLEAST 100 WORDS LONG";
        return reviewer_guide;
    }
    //cheks activation of this smart contract
    function checkActivation() external view returns(string memory){
        
        if(counter==1)
            return 'THIS CONTRACT IS ALREADY ACTIVATED';
        else
            return 'THIS CONTRACT IS NOT ACTIVATED';
    }
    
    //activates this smart CONTRACT
    function activate(string memory BOOK_link,uint to_each_reviewer) external payable {
        if(counter==1)                                  //if smart contract is already ACTIVATED
           
           revert();
        else if(msg.value==0||msg.value<to_each_reviewer){
        //IF INVESTMENT BY PUBLISHER IS INAPPROPIATE
            revert();
        }
        else{
        //IF EVERYTHING GOES RIGHT
            link=BOOK_link;        
            each=to_each_reviewer;
            counter++;
            // CONTRACT ACTIVATES
        }
    }
    
    //REVIEWER MARKS HIS ENTRY
    function markEntry(address Enter_your_address) external payable returns(string memory){
        if(msg.value==0||msg.value<100){
        //IF REVIEWER HAS NOT INVESTED PROPERLY
            revert();
        }
        else{
        //IF REVIEWER ALREADY GOT THHE LINK AND COMES AGAIN FOR IT
            if(reviewer_address[Enter_your_address].timestamp!=0){
                revert();
            }
            else{
            //if everything is OK HIS ENTRY IS MARKED
                reviewer_address[Enter_your_address].timestamp=block.timestamp;
                reviewer_address[Enter_your_address].paystatus=0;
                reviewer_address[Enter_your_address].validreview=0;
                return link;
            }
        }
    }
    
    //REVIEWER GETS THE LINK IF HIS ENTRY IS MARKED
    function getLink(address Enter_your_address) external view returns(string memory){
        if(reviewer_address[Enter_your_address].timestamp!=0)
            return link;
        else
            return 'MARK YOUR ENTRY FIRST';
        
    }
    //REVIER SUBMITS HIS REVIEW
    function submit_review(address Enter_your_address, string memory review ) public returns(string memory){
       
        if(reviewer_address[Enter_your_address].timestamp==0)
        //IF REVIEWER COMES STRAIGHT FOR THE REVIEW
            return 'GET LINK OF THE BOOK FIRST';
        else if ((reviewer_address[Enter_your_address].timestamp+(2*24*60*60))>block.timestamp)//IF REVIWER CAME BEFORE TEO DAYS
            return 'YOU CAME EARLY\nGO AND READ THE BOOK PROPERLY';
        else if (reviewer_address[Enter_your_address].paystatus==1)//IF REVIEWE IS ALREADY PAID AND COMES AGAIN WITH SAME ADDRESS
            return 'YOU ARE ALREADY PAID';
        else{
            //IF  HIS REVIEW FAILS OUR CRITERIA of string of lenght 500 or more HE LOSES HIS STAKE
            if(getStringLength(review)<500){
                reviewer_address[Enter_your_address].paystatus++;
                return 'YOU TRIED TO CHEAT\nLOST YOUR INVESTMENT';
            }
            else if(address(this).balance<(each+100)){
                //IF INVESTMENT OF ADVERTISER IS FINISHED
                return 'YOU ARE LATE\nLIMIT OF REVIEWS REACHED';
            }
            else{
            //IF EVERYTHING IS OK. HE IS PAID AND HIS PAYSTATUS IS UPDATED
                
                reviewer_address[Enter_your_address].validreview++;
                return 'AMOUT TRANSFERED';
            }
        }
        
    }
    
    //REVIEWER COLLECT THE REWARD IF HE HAS NOT COLLECTED IT PREVIOSLY AND HIS REVIEEW IS VALIDATED
    function collect(address payable Enter_your_address) external {
        if(reviewer_address[Enter_your_address].validreview==1&&reviewer_address[Enter_your_address].paystatus==0)
        {
            reviewer_address[Enter_your_address].paystatus++;
            Enter_your_address.transfer(each+100);
        }
        else
        revert();
    }
    function getStringLength(string memory _s) private pure returns (uint) {
    bytes memory bs = bytes(_s);
    return bs.length;
    }
}

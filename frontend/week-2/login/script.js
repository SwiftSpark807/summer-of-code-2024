const emailInput =  document.getElementById("email");
const passInput =document.getElementById("password");
const SubmitBtn = document.getElementById("SubmitBtn");
const passWordMsg = document.getElementById("password-messge");
const emailMsg = document.getElementById("email-messge");
let flag = false;
let flag2 = false;

function display(str1){
    passWordMsg.style.color="#ff3b3b";
    passWordMsg.textContent=str1;
    passInput.style.borderWidth="2px";
    passInput.style.borderColor="#ff3b3b";
    passWordMsg.style.backgroundColor="#ffdede";
    passWordMsg.style.fontWeight="bold";
}

function hasChar(a){
    for(let i=0; i<a.length; i++){
    if( a[i].toUpperCase() != a[i].toLowerCase() ){
        return true;
    }
    }
    return false;
    

}
function Num(b){
    return b.match(/\d+/) !== null;
  
}
function HasSymbol(c){
    for(let i=0; i<c.length; i++){
    let code = c.charCodeAt(i);
    if((code>=33 && code<=47) ||(code>=58 && code<=64) ||(code>=91 && code<=96) ||(code>=123 && code<=126)){
        console.log(code)
        return true; 
    }
    }   
    return false;   
}

function passWordCheck(password){
    if(password.length<8){
        
        display("password must atleast have 8 characters !!")

    }
    else if(!hasChar(password)){
        display("password must  have 1 alphabet !!")
    }
    else if(!Num(password)){
        display("password must  have 1 Number !!")

    }
    else if(!HasSymbol(password)){
        display("password must  have 1 Symbol !!")

    }
  
    else{
        passInput.style.borderWidth="2px";
        passInput.style.borderColor="#33ff55";
        passWordMsg.textContent="";
        flag2 = true;
        
    }

}
function validateEmail(email) {
    const re = /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/;
    return re.test(String(email).toLowerCase());
}
function emailCheck(email){
    if(!validateEmail(email)){
    emailMsg.style.color="#ff3b3b";
    emailMsg.textContent="Invalid email";
    emailInput.style.borderWidth="2px";
    emailInput.style.borderColor="#ff3b3b";
    emailMsg.style.backgroundColor="#ffdede";
    emailMsg.style.fontWeight="bold";

    }
    else{
    emailInput.style.borderWidth="2px";
    emailInput.style.borderColor="#33ff55";
    emailMsg.textContent="";
    flag=true;
    }
    

}
SubmitBtn.onclick = function(){
    let email = emailInput.value.trim();
    let password = passInput.value.trim();
    emailCheck(email);
    if(flag) passWordCheck(password);
    if(flag && flag2)setTimeout(()=>{
        window.open("/frontend/week-2/success/success.html", "_self");
        flag=false;
        flag2=false;
    
    },1000);
    
}
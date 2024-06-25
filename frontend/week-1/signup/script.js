const emailInput =  document.getElementById("email");
const passInput =document.getElementById("password");
const userInput =document.getElementById("username");
const confirmPassInput =document.getElementById("confirmpass");
const SubmitBtn = document.getElementById("SubmitBtn");
const passWordMsg = document.getElementById("password-messge");
const emailMsg = document.getElementById("email-messge");
const confPassMsg = document.getElementById("confirm-pass-message");
const usernameMsg = document.getElementById("username-messge");

let flag = false;
let flag1 = false;
let flag2 = false;
let flag3 = false;
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
    flag1=true;
    }
    

}
function userNameCheck(username){
    if(username.length<4){
        usernameMsg.style.color="#ff3b3b";
        usernameMsg.textContent="Username must be of 4 characters";
        userInput.style.borderWidth="2px";
        userInput.style.borderColor="#ff3b3b";
        usernameMsg.style.backgroundColor="#ffdede";
        usernameMsg.style.fontWeight="bold";

    }
    else if(!hasChar(username)){
        usernameMsg.style.color="#ff3b3b";
        usernameMsg.textContent="Username must be of at least 1 letter";
        userInput.style.borderWidth="2px";
        userInput.style.borderColor="#ff3b3b";
        usernameMsg.style.backgroundColor="#ffdede";
        usernameMsg.style.fontWeight="bold";
    }
    else{
        userInput.style.borderWidth="2px";
        userInput.style.borderColor="#33ff55";
        usernameMsg.textContent="";
        flag=true;

    }

}
function confirmPass(confPass, password){
    if(confPass.length<1){
        confPassMsg.style.color="#ff3b3b";
        confPassMsg.textContent="Enter Password to Confirm !!";
        confirmPassInput.style.borderWidth="2px";
        confirmPassInput.style.borderColor="#ff3b3b";
        confPassMsg.style.backgroundColor="#ffdede";
        confPassMsg.style.fontWeight="bold";
    }
    else if(confPass!=password){
        confPassMsg.style.color="#ff3b3b";
        confPassMsg.textContent="Passwords Should Match!!";
        confPassMsg.style.backgroundColor="#ffdede";
        confPassMsg.style.fontWeight="bold";
        confirmPassInput.style.borderWidth="2px";
        confirmPassInput.style.borderColor="#ff3b3b";

    }
    else{
        confirmPassInput.style.borderWidth="2px";
        confirmPassInput.style.borderColor="#33ff55";
        confPassMsg.textContent="";
        flag3 = true;
        
    }
}
SubmitBtn.onclick = function(){

    let email = emailInput.value.trim();
    let password = passInput.value.trim();
    let confPass = confirmPassInput.value.trim();
    let username = userInput.value.trim();
    
    userNameCheck(username);
    if(flag)emailCheck(email);
    if(flag1) passWordCheck(password);
    if(flag2)confirmPass(confPass,password);
    if(flag && flag1 && flag2 && flag3){setTimeout(()=>{
        window.open("/frontend/week-1/login/login.html", "_self");
        flag=false;
        flag1= false;
        flag2=false;
        flag3=false;
       
    },1000);
    usernameMsg.style.visibility="invisible";
    }
    else{
        usernameMsg.style.color="#ff3b3b";
        
        usernameMsg.style.backgroundColor="#ffdede";
        

    }
    
}
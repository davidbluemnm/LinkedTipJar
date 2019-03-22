// Channel to communicate on. Must be set to the same number on every tipjar. Use a random negative integer
integer listenChannel = -7843293;

// Hovertext message - %%TOTALDONATED%% will be replaced with the total donated so far
string hoverMessage = "Donation Box\nAny donations are appreciated!\nL$%%TOTALDONATED%% Donated so far.";

// Color of the hovertext
vector hoverColor = <1.0, 1.0, 1.0>;

// Thank you message sent to tipper
string thankYouMessage = "Thank you, your donation is appreciated!";

// Value to display in the pay field
integer payField = 50;

// Prices to show on pay buttons
list prices = [100, 250, 500, 1000];

// DO NOT CHANGE BELOW THIS LINE //

integer totalDonated;
key owner;
integer listenHandle;

string strReplace(string str, string search, string replace) {
    return llDumpList2String(llParseStringKeepNulls((str = "") + str, [search], []), replace);
}


default {
    on_rez( integer sparam ) {
        llResetScript();
    }

    state_entry() {
        owner = llGetOwner();
        llSetText(strReplace(hoverMessage, "%%TOTALDONATED%%", "0"), hoverColor, 1.0);
        llSetPayPrice(payField, prices);
        listenHandle = llListen(listenChannel, "", "", "");
        llSetClickAction(CLICK_ACTION_PAY);
        llRegionSay(listenChannel, "ZZZRESET");
    }
    

    money(key id, integer amount) {
        totalDonated += amount;
        llSetText(strReplace(hoverMessage, "%%TOTALDONATED%%", (string)totalDonated), hoverColor, 1.0);
        llRegionSayTo(id, 0, thankYouMessage);
        llOwnerSay(llKey2Name(id)+" donated L$" + (string)amount);
        llRegionSay(listenChannel, "DONATE|" + (string)amount);
    }
            
    listen(integer channel, string name, key id, string message) {
        if (channel==listenChannel) {
            list data = llParseString2List(message, ["|"],[]);
            if (llGetListLength(data) == 2) {
                if(llList2String(data, 0) == "DONATE") {
                    totalDonated += (integer)llList2String(data, 1);
                    llSetText(strReplace(hoverMessage, "%%TOTALDONATED%%", (string)totalDonated), hoverColor, 1.0);
                }
            } else if (message == "ZZZRESET") {
                totalDonated = 0;
                llSetText(strReplace(hoverMessage, "%%TOTALDONATED%%", "0"), hoverColor, 1.0);
            }
        }
    }
}

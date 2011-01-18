	function set_description(index) {
	try {
		var text1 = document.getElementById("brief1").innerHTML
		var text2 = document.getElementById("brief2").innerHTML
		switch (index){
			case 0: document.getElementById("order_description").value = text1;
			break;
			case 1: document.getElementById("order_description").value = text1;
			break;
			case 2: document.getElementById("order_description").value = text2;
			break;
			case 3: document.getElementById("order_description").value = text2;
			break;
		}
	}
	catch(e)
	{alert('Error'+e.toString()); throw e;}
	return false
}

	function taLimit(taObj) {
		if (taObj.value.length > maxL) return false;
		else return true;
	}
	
	function taCount(e, taObj, counter_id, maxL) {
		objCounter = document.getElementById(counter_id);
		objVal = taObj.value;
		if (e.keyCode == 86 || e.keyCode == 17) {//do not truncate on <C-v> event
			objCounter.innerText = objVal.length;
		}
		else {
			if (objVal.length > maxL) {
				taObj.value = objVal.substring(0, maxL);
				objCounter.innerText = maxL;
			}
			else {
				objCounter.innerText = objVal.length;
			}
		}
	}

	function showPrivate(value){
		if (value) {
			Element.show('status_private');
			document.getElementById('order_privacy_open').checked = false;
		}
		else {
			Element.hide('status_private');
			document.getElementById('order_privacy').checked = value;
		}
	}

    function updateCostDependency(){
       var cost = document.getElementById('order_cost').value;
       document.getElementById('commission').innerHTML = parseInt(cost) * 0.1;
    }

({

    sortProductCategories: function(productMap) {

        console.log('ProductListHelper > sortProductCategories');

        // create category array similar to the data table data for sorting
        var data = Array();
        for (var [key, value] of productMap) {
            var dataItem = {};
            dataItem.category = key;
            data.push(dataItem);
        }

        // sort categories
        var fieldName = 'category';
        var sortDirection = 'asc';
        data = this.sortData(data, fieldName, sortDirection);

        // create new productMap with the sorted categories
        var newProductMap = new Map();
        for (var i = 0; i < data.length; ++i) {
            var category = data[i].category;
            //console.log('category ' + i + ': ' + category);

            for (var [key, value] of productMap) {
                if (key == category) {
                    var categoryProductList = productMap.get(category);
                    newProductMap.set(category, categoryProductList);
                }
            }
        } // end for sorted categories

        return newProductMap;

    }, // end sortProductCategories

   sortData: function (data, fieldName, sortDirection) {

        var reverse = sortDirection !== 'asc';
        data = Object.assign([],
            data.sort(this.sortBy(fieldName, reverse ? -1 : 1))
        );
        return data;

    }, // end sortData

    sortBy: function (field, reverse, primer) {
        var key = primer
            ? function(x) { return primer(x[field]) }
            : function(x) { return x[field] };

        return function (a, b) {
            var A = key(a);
            var B = key(b);
            return reverse * ((A > B) - (B > A));
        };
    }, // end sortBy


})
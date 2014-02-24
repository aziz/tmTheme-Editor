/*
 *  Sugar Library v1.4.1
 *
 *  Freely distributable and licensed under the MIT-style license.
 *  Copyright (c) 2013 Andrew Plummer
 *  http://sugarjs.com/
 *
 * ---------------------------- */
(function(){
  /***
   * @package Core
   * @description Internal utility and common methods.
   ***/


  // A few optimizations for Google Closure Compiler will save us a couple kb in the release script.
  var object = Object, array = Array, regexp = RegExp, date = Date, string = String, number = Number, math = Math, Undefined;

  // The global context
  var globalContext = typeof global !== 'undefined' ? global : this;

  // Internal toString
  var internalToString = object.prototype.toString;

  // Internal hasOwnProperty
  var internalHasOwnProperty = object.prototype.hasOwnProperty;

  // defineProperty exists in IE8 but will error when trying to define a property on
  // native objects. IE8 does not have defineProperies, however, so this check saves a try/catch block.
  var definePropertySupport = object.defineProperty && object.defineProperties;

  // Are regexes type function?
  var regexIsFunction = typeof regexp() === 'function';

  // Do strings have no keys?
  var noKeysInStringObjects = !('0' in new string('a'));

  // Type check methods need a way to be accessed dynamically.
  var typeChecks = {};

  // Classes that can be matched by value
  var matchedByValueReg = /^\[object Date|Array|String|Number|RegExp|Boolean|Arguments\]$/;

  // Class initializers and class helpers
  var ClassNames = 'Boolean,Number,String,Array,Date,RegExp,Function'.split(',');

  var isBoolean  = buildPrimitiveClassCheck('boolean', ClassNames[0]);
  var isNumber   = buildPrimitiveClassCheck('number',  ClassNames[1]);
  var isString   = buildPrimitiveClassCheck('string',  ClassNames[2]);

  var isArray    = buildClassCheck(ClassNames[3]);
  var isDate     = buildClassCheck(ClassNames[4]);
  var isRegExp   = buildClassCheck(ClassNames[5]);


  // Wanted to enhance performance here by using simply "typeof"
  // but Firefox has two major issues that make this impossible,
  // one fixed, the other not. Despite being typeof "function"
  // the objects below still report in as [object Function], so
  // we need to perform a full class check here.
  //
  // 1. Regexes can be typeof "function" in FF < 3
  //    https://bugzilla.mozilla.org/show_bug.cgi?id=61911 (fixed)
  //
  // 2. HTMLEmbedElement and HTMLObjectElement are be typeof "function"
  //    https://bugzilla.mozilla.org/show_bug.cgi?id=268945 (won't fix)
  //
  var isFunction = buildClassCheck(ClassNames[6]);

  function isClass(obj, klass, cached) {
    var k = cached || className(obj);
    return k === '[object '+klass+']';
  }

  function buildClassCheck(klass) {
    var fn = (klass === 'Array' && array.isArray) || function(obj, cached) {
      return isClass(obj, klass, cached);
    };
    typeChecks[klass] = fn;
    return fn;
  }

  function buildPrimitiveClassCheck(type, klass) {
    var fn = function(obj) {
      if(isObjectType(obj)) {
        return isClass(obj, klass);
      }
      return typeof obj === type;
    }
    typeChecks[klass] = fn;
    return fn;
  }

  function className(obj) {
    return internalToString.call(obj);
  }

  function initializeClasses() {
    initializeClass(object);
    iterateOverObject(ClassNames, function(i,name) {
      initializeClass(globalContext[name]);
    });
  }

  function initializeClass(klass) {
    if(klass['SugarMethods']) return;
    defineProperty(klass, 'SugarMethods', {});
    extend(klass, false, true, {
      'extend': function(methods, override, instance) {
        extend(klass, instance !== false, override, methods);
      },
      'sugarRestore': function() {
        return batchMethodExecute(this, klass, arguments, function(target, name, m) {
          defineProperty(target, name, m.method);
        });
      },
      'sugarRevert': function() {
        return batchMethodExecute(this, klass, arguments, function(target, name, m) {
          if(m['existed']) {
            defineProperty(target, name, m['original']);
          } else {
            delete target[name];
          }
        });
      }
    });
  }

  // Class extending methods

  function extend(klass, instance, override, methods) {
    var extendee = instance ? klass.prototype : klass;
    initializeClass(klass);
    iterateOverObject(methods, function(name, extendedFn) {
      var nativeFn = extendee[name],
          existed  = hasOwnProperty(extendee, name);
      if(isFunction(override) && nativeFn) {
        extendedFn = wrapNative(nativeFn, extendedFn, override);
      }
      if(override !== false || !nativeFn) {
        defineProperty(extendee, name, extendedFn);
      }
      // If the method is internal to Sugar, then
      // store a reference so it can be restored later.
      klass['SugarMethods'][name] = {
        'method':   extendedFn,
        'existed':  existed,
        'original': nativeFn,
        'instance': instance
      };
    });
  }

  function extendSimilar(klass, instance, override, set, fn) {
    var methods = {};
    set = isString(set) ? set.split(',') : set;
    set.forEach(function(name, i) {
      fn(methods, name, i);
    });
    extend(klass, instance, override, methods);
  }

  function batchMethodExecute(target, klass, args, fn) {
    var all = args.length === 0, methods = multiArgs(args), changed = false;
    iterateOverObject(klass['SugarMethods'], function(name, m) {
      if(all || methods.indexOf(name) !== -1) {
        changed = true;
        fn(m['instance'] ? target.prototype : target, name, m);
      }
    });
    return changed;
  }

  function wrapNative(nativeFn, extendedFn, condition) {
    return function(a) {
      return condition.apply(this, arguments) ?
             extendedFn.apply(this, arguments) :
             nativeFn.apply(this, arguments);
    }
  }

  function defineProperty(target, name, method) {
    if(definePropertySupport) {
      object.defineProperty(target, name, {
        'value': method,
        'configurable': true,
        'enumerable': false,
        'writable': true
      });
    } else {
      target[name] = method;
    }
  }


  // Argument helpers

  function multiArgs(args, fn, from) {
    var result = [], i = from || 0, len;
    for(len = args.length; i < len; i++) {
      result.push(args[i]);
      if(fn) fn.call(args, args[i], i);
    }
    return result;
  }

  function flattenedArgs(args, fn, from) {
    var arg = args[from || 0];
    if(isArray(arg)) {
      args = arg;
      from = 0;
    }
    return multiArgs(args, fn, from);
  }

  function checkCallback(fn) {
    if(!fn || !fn.call) {
      throw new TypeError('Callback is not callable');
    }
  }


  // General helpers

  function isDefined(o) {
    return o !== Undefined;
  }

  function isUndefined(o) {
    return o === Undefined;
  }


  // Object helpers

  function hasProperty(obj, prop) {
    return !isPrimitiveType(obj) && prop in obj;
  }

  function hasOwnProperty(obj, prop) {
    return !!obj && internalHasOwnProperty.call(obj, prop);
  }

  function isObjectType(obj) {
    // 1. Check for null
    // 2. Check for regexes in environments where they are "functions".
    return !!obj && (typeof obj === 'object' || (regexIsFunction && isRegExp(obj)));
  }

  function isPrimitiveType(obj) {
    var type = typeof obj;
    return obj == null || type === 'string' || type === 'number' || type === 'boolean';
  }

  function isPlainObject(obj, klass) {
    klass = klass || className(obj);
    try {
      // Not own constructor property must be Object
      // This code was borrowed from jQuery.isPlainObject
      if (obj && obj.constructor &&
            !hasOwnProperty(obj, 'constructor') &&
            !hasOwnProperty(obj.constructor.prototype, 'isPrototypeOf')) {
        return false;
      }
    } catch (e) {
      // IE8,9 Will throw exceptions on certain host objects.
      return false;
    }
    // === on the constructor is not safe across iframes
    // 'hasOwnProperty' ensures that the object also inherits
    // from Object, which is false for DOMElements in IE.
    return !!obj && klass === '[object Object]' && 'hasOwnProperty' in obj;
  }

  function iterateOverObject(obj, fn) {
    var key;
    for(key in obj) {
      if(!hasOwnProperty(obj, key)) continue;
      if(fn.call(obj, key, obj[key], obj) === false) break;
    }
  }

  function simpleRepeat(n, fn) {
    for(var i = 0; i < n; i++) {
      fn(i);
    }
  }

  function simpleMerge(target, source) {
    iterateOverObject(source, function(key) {
      target[key] = source[key];
    });
    return target;
  }

   // Make primtives types like strings into objects.
   function coercePrimitiveToObject(obj) {
     if(isPrimitiveType(obj)) {
       obj = object(obj);
     }
     if(noKeysInStringObjects && isString(obj)) {
       forceStringCoercion(obj);
     }
     return obj;
   }

   // Force strings to have their indexes set in
   // environments that don't do this automatically.
   function forceStringCoercion(obj) {
     var i = 0, chr;
     while(chr = obj.charAt(i)) {
       obj[i++] = chr;
     }
   }

  // Hash definition

  function Hash(obj) {
    simpleMerge(this, coercePrimitiveToObject(obj));
  };

  Hash.prototype.constructor = object;

  // Math helpers

  var abs   = math.abs;
  var pow   = math.pow;
  var ceil  = math.ceil;
  var floor = math.floor;
  var round = math.round;
  var min   = math.min;
  var max   = math.max;

  function withPrecision(val, precision, fn) {
    var multiplier = pow(10, abs(precision || 0));
    fn = fn || round;
    if(precision < 0) multiplier = 1 / multiplier;
    return fn(val * multiplier) / multiplier;
  }

  // Full width number helpers

  var HalfWidthZeroCode = 0x30;
  var HalfWidthNineCode = 0x39;
  var FullWidthZeroCode = 0xff10;
  var FullWidthNineCode = 0xff19;

  var HalfWidthPeriod = '.';
  var FullWidthPeriod = '．';
  var HalfWidthComma  = ',';

  // Used here and later in the Date package.
  var FullWidthDigits   = '';

  var NumberNormalizeMap = {};
  var NumberNormalizeReg;

  function codeIsNumeral(code) {
    return (code >= HalfWidthZeroCode && code <= HalfWidthNineCode) ||
           (code >= FullWidthZeroCode && code <= FullWidthNineCode);
  }

  function buildNumberHelpers() {
    var digit, i;
    for(i = 0; i <= 9; i++) {
      digit = chr(i + FullWidthZeroCode);
      FullWidthDigits += digit;
      NumberNormalizeMap[digit] = chr(i + HalfWidthZeroCode);
    }
    NumberNormalizeMap[HalfWidthComma] = '';
    NumberNormalizeMap[FullWidthPeriod] = HalfWidthPeriod;
    // Mapping this to itself to easily be able to easily
    // capture it in stringToNumber to detect decimals later.
    NumberNormalizeMap[HalfWidthPeriod] = HalfWidthPeriod;
    NumberNormalizeReg = regexp('[' + FullWidthDigits + FullWidthPeriod + HalfWidthComma + HalfWidthPeriod + ']', 'g');
  }

  // String helpers

  function chr(num) {
    return string.fromCharCode(num);
  }

  // WhiteSpace/LineTerminator as defined in ES5.1 plus Unicode characters in the Space, Separator category.
  function getTrimmableCharacters() {
    return '\u0009\u000A\u000B\u000C\u000D\u0020\u00A0\u1680\u180E\u2000\u2001\u2002\u2003\u2004\u2005\u2006\u2007\u2008\u2009\u200A\u202F\u205F\u2028\u2029\u3000\uFEFF';
  }

  function repeatString(str, num) {
    var result = '', str = str.toString();
    while (num > 0) {
      if (num & 1) {
        result += str;
      }
      if (num >>= 1) {
        str += str;
      }
    }
    return result;
  }

  // Returns taking into account full-width characters, commas, and decimals.
  function stringToNumber(str, base) {
    var sanitized, isDecimal;
    sanitized = str.replace(NumberNormalizeReg, function(chr) {
      var replacement = NumberNormalizeMap[chr];
      if(replacement === HalfWidthPeriod) {
        isDecimal = true;
      }
      return replacement;
    });
    return isDecimal ? parseFloat(sanitized) : parseInt(sanitized, base || 10);
  }


  // Used by Number and Date

  function padNumber(num, place, sign, base) {
    var str = abs(num).toString(base || 10);
    str = repeatString('0', place - str.replace(/\.\d+/, '').length) + str;
    if(sign || num < 0) {
      str = (num < 0 ? '-' : '+') + str;
    }
    return str;
  }

  function getOrdinalizedSuffix(num) {
    if(num >= 11 && num <= 13) {
      return 'th';
    } else {
      switch(num % 10) {
        case 1:  return 'st';
        case 2:  return 'nd';
        case 3:  return 'rd';
        default: return 'th';
      }
    }
  }


  // RegExp helpers

  function getRegExpFlags(reg, add) {
    var flags = '';
    add = add || '';
    function checkFlag(prop, flag) {
      if(prop || add.indexOf(flag) > -1) {
        flags += flag;
      }
    }
    checkFlag(reg.multiline, 'm');
    checkFlag(reg.ignoreCase, 'i');
    checkFlag(reg.global, 'g');
    checkFlag(reg.sticky, 'y');
    return flags;
  }

  function escapeRegExp(str) {
    if(!isString(str)) str = string(str);
    return str.replace(/([\\/\'*+?|()\[\]{}.^$])/g,'\\$1');
  }


  // Date helpers

  function callDateGet(d, method) {
    return d['get' + (d._utc ? 'UTC' : '') + method]();
  }

  function callDateSet(d, method, value) {
    return d['set' + (d._utc && method != 'ISOWeek' ? 'UTC' : '') + method](value);
  }

  // Used by Array#unique and Object.equal

  function stringify(thing, stack) {
    var type = typeof thing,
        thingIsObject,
        thingIsArray,
        klass, value,
        arr, key, i, len;

    // Return quickly if string to save cycles
    if(type === 'string') return thing;

    klass         = internalToString.call(thing)
    thingIsObject = isPlainObject(thing, klass);
    thingIsArray  = isArray(thing, klass);

    if(thing != null && thingIsObject || thingIsArray) {
      // This method for checking for cyclic structures was egregiously stolen from
      // the ingenious method by @kitcambridge from the Underscore script:
      // https://github.com/documentcloud/underscore/issues/240
      if(!stack) stack = [];
      // Allowing a step into the structure before triggering this
      // script to save cycles on standard JSON structures and also to
      // try as hard as possible to catch basic properties that may have
      // been modified.
      if(stack.length > 1) {
        i = stack.length;
        while (i--) {
          if (stack[i] === thing) {
            return 'CYC';
          }
        }
      }
      stack.push(thing);
      value = thing.valueOf() + string(thing.constructor);
      arr = thingIsArray ? thing : object.keys(thing).sort();
      for(i = 0, len = arr.length; i < len; i++) {
        key = thingIsArray ? i : arr[i];
        value += key + stringify(thing[key], stack);
      }
      stack.pop();
    } else if(1 / thing === -Infinity) {
      value = '-0';
    } else {
      value = string(thing && thing.valueOf ? thing.valueOf() : thing);
    }
    return type + klass + value;
  }

  function isEqual(a, b) {
    if(a === b) {
      // Return quickly up front when matching by reference,
      // but be careful about 0 !== -0.
      return a !== 0 || 1 / a === 1 / b;
    } else if(objectIsMatchedByValue(a) && objectIsMatchedByValue(b)) {
      return stringify(a) === stringify(b);
    }
    return false;
  }

  function objectIsMatchedByValue(obj) {
    // Only known objects are matched by value. This is notably excluding functions, DOM Elements, and instances of
    // user-created classes. The latter can arguably be matched by value, but distinguishing between these and
    // host objects -- which should never be compared by value -- is very tricky so not dealing with it here.
    var klass = className(obj);
    return matchedByValueReg.test(klass) || isPlainObject(obj, klass);
  }


  // Used by Array#at and String#at

  function getEntriesForIndexes(obj, args, isString) {
    var result,
        length    = obj.length,
        argsLen   = args.length,
        overshoot = args[argsLen - 1] !== false,
        multiple  = argsLen > (overshoot ? 1 : 2);
    if(!multiple) {
      return entryAtIndex(obj, length, args[0], overshoot, isString);
    }
    result = [];
    multiArgs(args, function(index) {
      if(isBoolean(index)) return false;
      result.push(entryAtIndex(obj, length, index, overshoot, isString));
    });
    return result;
  }

  function entryAtIndex(obj, length, index, overshoot, isString) {
    if(overshoot) {
      index = index % length;
      if(index < 0) index = length + index;
    }
    return isString ? obj.charAt(index) : obj[index];
  }


  // Object class methods implemented as instance methods

  function buildObjectInstanceMethods(set, target) {
    extendSimilar(target, true, false, set, function(methods, name) {
      methods[name + (name === 'equal' ? 's' : '')] = function() {
        return object[name].apply(null, [this].concat(multiArgs(arguments)));
      }
    });
  }

  initializeClasses();
  buildNumberHelpers();


  /***
   * @package Array
   * @dependency core
   * @description Array manipulation and traversal, "fuzzy matching" against elements, alphanumeric sorting and collation, enumerable methods on Object.
   *
   ***/


  function regexMatcher(reg) {
    reg = regexp(reg);
    return function (el) {
      return reg.test(el);
    }
  }

  function dateMatcher(d) {
    var ms = d.getTime();
    return function (el) {
      return !!(el && el.getTime) && el.getTime() === ms;
    }
  }

  function functionMatcher(fn) {
    return function (el, i, arr) {
      // Return true up front if match by reference
      return el === fn || fn.call(this, el, i, arr);
    }
  }

  function invertedArgsFunctionMatcher(fn) {
    return function (value, key, obj) {
      // Return true up front if match by reference
      return value === fn || fn.call(obj, key, value, obj);
    }
  }

  function fuzzyMatcher(obj, isObject) {
    var matchers = {};
    return function (el, i, arr) {
      var key;
      if(!isObjectType(el)) {
        return false;
      }
      for(key in obj) {
        matchers[key] = matchers[key] || getMatcher(obj[key], isObject);
        if(matchers[key].call(arr, el[key], i, arr) === false) {
          return false;
        }
      }
      return true;
    }
  }

  function defaultMatcher(f) {
    return function (el) {
      return el === f || isEqual(el, f);
    }
  }

  function getMatcher(f, isObject) {
    if(isPrimitiveType(f)) {
      // Do nothing and fall through to the
      // default matcher below.
    } else if(isRegExp(f)) {
      // Match against a regexp
      return regexMatcher(f);
    } else if(isDate(f)) {
      // Match against a date. isEqual below should also
      // catch this but matching directly up front for speed.
      return dateMatcher(f);
    } else if(isFunction(f)) {
      // Match against a filtering function
      if(isObject) {
        return invertedArgsFunctionMatcher(f);
      } else {
        return functionMatcher(f);
      }
    } else if(isPlainObject(f)) {
      // Match against a fuzzy hash or array.
      return fuzzyMatcher(f, isObject);
    }
    // Default is standard isEqual
    return defaultMatcher(f);
  }

  function transformArgument(el, map, context, mapArgs) {
    if(!map) {
      return el;
    } else if(map.apply) {
      return map.apply(context, mapArgs || []);
    } else if(isFunction(el[map])) {
      return el[map].call(el);
    } else {
      return el[map];
    }
  }

  // Basic array internal methods

  function arrayEach(arr, fn, startIndex, loop) {
    var index, i, length = +arr.length;
    if(startIndex < 0) startIndex = arr.length + startIndex;
    i = isNaN(startIndex) ? 0 : startIndex;
    if(loop === true) {
      length += i;
    }
    while(i < length) {
      index = i % arr.length;
      if(!(index in arr)) {
        return iterateOverSparseArray(arr, fn, i, loop);
      } else if(fn.call(arr, arr[index], index, arr) === false) {
        break;
      }
      i++;
    }
  }

  function iterateOverSparseArray(arr, fn, fromIndex, loop) {
    var indexes = [], i;
    for(i in arr) {
      if(isArrayIndex(arr, i) && i >= fromIndex) {
        indexes.push(parseInt(i));
      }
    }
    indexes.sort().each(function(index) {
      return fn.call(arr, arr[index], index, arr);
    });
    return arr;
  }

  function isArrayIndex(arr, i) {
    return i in arr && toUInt32(i) == i && i != 0xffffffff;
  }

  function toUInt32(i) {
    return i >>> 0;
  }

  function arrayFind(arr, f, startIndex, loop, returnIndex, context) {
    var result, index, matcher;
    if(arr.length > 0) {
      matcher = getMatcher(f);
      arrayEach(arr, function(el, i) {
        if(matcher.call(context, el, i, arr)) {
          result = el;
          index = i;
          return false;
        }
      }, startIndex, loop);
    }
    return returnIndex ? index : result;
  }

  function arrayUnique(arr, map) {
    var result = [], o = {}, transformed;
    arrayEach(arr, function(el, i) {
      transformed = map ? transformArgument(el, map, arr, [el, i, arr]) : el;
      if(!checkForElementInHashAndSet(o, transformed)) {
        result.push(el);
      }
    })
    return result;
  }

  function arrayIntersect(arr1, arr2, subtract) {
    var result = [], o = {};
    arr2.each(function(el) {
      checkForElementInHashAndSet(o, el);
    });
    arr1.each(function(el) {
      var stringified = stringify(el),
          isReference = !objectIsMatchedByValue(el);
      // Add the result to the array if:
      // 1. We're subtracting intersections or it doesn't already exist in the result and
      // 2. It exists in the compared array and we're adding, or it doesn't exist and we're removing.
      if(elementExistsInHash(o, stringified, el, isReference) !== subtract) {
        discardElementFromHash(o, stringified, el, isReference);
        result.push(el);
      }
    });
    return result;
  }

  function arrayFlatten(arr, level, current) {
    level = level || Infinity;
    current = current || 0;
    var result = [];
    arrayEach(arr, function(el) {
      if(isArray(el) && current < level) {
        result = result.concat(arrayFlatten(el, level, current + 1));
      } else {
        result.push(el);
      }
    });
    return result;
  }

  function isArrayLike(obj) {
    return hasProperty(obj, 'length') && !isString(obj) && !isPlainObject(obj);
  }

  function isArgumentsObject(obj) {
    // .callee exists on Arguments objects in < IE8
    return hasProperty(obj, 'length') && (className(obj) === '[object Arguments]' || !!obj.callee);
  }

  function flatArguments(args) {
    var result = [];
    multiArgs(args, function(arg) {
      result = result.concat(arg);
    });
    return result;
  }

  function elementExistsInHash(hash, key, element, isReference) {
    var exists = key in hash;
    if(isReference) {
      if(!hash[key]) {
        hash[key] = [];
      }
      exists = hash[key].indexOf(element) !== -1;
    }
    return exists;
  }

  function checkForElementInHashAndSet(hash, element) {
    var stringified = stringify(element),
        isReference = !objectIsMatchedByValue(element),
        exists      = elementExistsInHash(hash, stringified, element, isReference);
    if(isReference) {
      hash[stringified].push(element);
    } else {
      hash[stringified] = element;
    }
    return exists;
  }

  function discardElementFromHash(hash, key, element, isReference) {
    var arr, i = 0;
    if(isReference) {
      arr = hash[key];
      while(i < arr.length) {
        if(arr[i] === element) {
          arr.splice(i, 1);
        } else {
          i += 1;
        }
      }
    } else {
      delete hash[key];
    }
  }

  // Support methods

  function getMinOrMax(obj, map, which, all) {
    var el,
        key,
        edge,
        test,
        result = [],
        max = which === 'max',
        min = which === 'min',
        isArray = array.isArray(obj);
    for(key in obj) {
      if(!obj.hasOwnProperty(key)) continue;
      el   = obj[key];
      test = transformArgument(el, map, obj, isArray ? [el, parseInt(key), obj] : []);
      if(isUndefined(test)) {
        throw new TypeError('Cannot compare with undefined');
      }
      if(test === edge) {
        result.push(el);
      } else if(isUndefined(edge) || (max && test > edge) || (min && test < edge)) {
        result = [el];
        edge = test;
      }
    }
    if(!isArray) result = arrayFlatten(result, 1);
    return all ? result : result[0];
  }


  // Alphanumeric collation helpers

  function collateStrings(a, b) {
    var aValue, bValue, aChar, bChar, aEquiv, bEquiv, index = 0, tiebreaker = 0;

    var sortIgnore      = array[AlphanumericSortIgnore];
    var sortIgnoreCase  = array[AlphanumericSortIgnoreCase];
    var sortEquivalents = array[AlphanumericSortEquivalents];
    var sortOrder       = array[AlphanumericSortOrder];
    var naturalSort     = array[AlphanumericSortNatural];

    a = getCollationReadyString(a, sortIgnore, sortIgnoreCase);
    b = getCollationReadyString(b, sortIgnore, sortIgnoreCase);

    do {

      aChar  = getCollationCharacter(a, index, sortEquivalents);
      bChar  = getCollationCharacter(b, index, sortEquivalents);
      aValue = getSortOrderIndex(aChar, sortOrder);
      bValue = getSortOrderIndex(bChar, sortOrder);

      if(aValue === -1 || bValue === -1) {
        aValue = a.charCodeAt(index) || null;
        bValue = b.charCodeAt(index) || null;
        if(naturalSort && codeIsNumeral(aValue) && codeIsNumeral(bValue)) {
          aValue = stringToNumber(a.slice(index));
          bValue = stringToNumber(b.slice(index));
        }
      } else {
        aEquiv = aChar !== a.charAt(index);
        bEquiv = bChar !== b.charAt(index);
        if(aEquiv !== bEquiv && tiebreaker === 0) {
          tiebreaker = aEquiv - bEquiv;
        }
      }
      index += 1;
    } while(aValue != null && bValue != null && aValue === bValue);
    if(aValue === bValue) return tiebreaker;
    return aValue - bValue;
  }

  function getCollationReadyString(str, sortIgnore, sortIgnoreCase) {
    if(!isString(str)) str = string(str);
    if(sortIgnoreCase) {
      str = str.toLowerCase();
    }
    if(sortIgnore) {
      str = str.replace(sortIgnore, '');
    }
    return str;
  }

  function getCollationCharacter(str, index, sortEquivalents) {
    var chr = str.charAt(index);
    return sortEquivalents[chr] || chr;
  }

  function getSortOrderIndex(chr, sortOrder) {
    if(!chr) {
      return null;
    } else {
      return sortOrder.indexOf(chr);
    }
  }

  var AlphanumericSort            = 'AlphanumericSort';
  var AlphanumericSortOrder       = 'AlphanumericSortOrder';
  var AlphanumericSortIgnore      = 'AlphanumericSortIgnore';
  var AlphanumericSortIgnoreCase  = 'AlphanumericSortIgnoreCase';
  var AlphanumericSortEquivalents = 'AlphanumericSortEquivalents';
  var AlphanumericSortNatural     = 'AlphanumericSortNatural';



  function buildEnhancements() {
    var nativeMap = array.prototype.map;
    var callbackCheck = function() {
      var args = arguments;
      return args.length > 0 && !isFunction(args[0]);
    };
    extendSimilar(array, true, callbackCheck, 'every,all,some,filter,any,none,find,findIndex', function(methods, name) {
      var nativeFn = array.prototype[name]
      methods[name] = function(f) {
        var matcher = getMatcher(f);
        return nativeFn.call(this, function(el, index) {
          return matcher(el, index, this);
        });
      }
    });
    extend(array, true, callbackCheck, {
      'map': function(f) {
        return nativeMap.call(this, function(el, index) {
          return transformArgument(el, f, this, [el, index, this]);
        });
      }
    });
  }

  function buildAlphanumericSort() {
    var order = 'AÁÀÂÃĄBCĆČÇDĎÐEÉÈĚÊËĘFGĞHıIÍÌİÎÏJKLŁMNŃŇÑOÓÒÔPQRŘSŚŠŞTŤUÚÙŮÛÜVWXYÝZŹŻŽÞÆŒØÕÅÄÖ';
    var equiv = 'AÁÀÂÃÄ,CÇ,EÉÈÊË,IÍÌİÎÏ,OÓÒÔÕÖ,Sß,UÚÙÛÜ';
    array[AlphanumericSortOrder] = order.split('').map(function(str) {
      return str + str.toLowerCase();
    }).join('');
    var equivalents = {};
    arrayEach(equiv.split(','), function(set) {
      var equivalent = set.charAt(0);
      arrayEach(set.slice(1).split(''), function(chr) {
        equivalents[chr] = equivalent;
        equivalents[chr.toLowerCase()] = equivalent.toLowerCase();
      });
    });
    array[AlphanumericSortNatural] = true;
    array[AlphanumericSortIgnoreCase] = true;
    array[AlphanumericSortEquivalents] = equivalents;
  }

  extend(array, false, true, {

    /***
     *
     * @method Array.create(<obj1>, <obj2>, ...)
     * @returns Array
     * @short Alternate array constructor.
     * @extra This method will create a single array by calling %concat% on all arguments passed. In addition to ensuring that an unknown variable is in a single, flat array (the standard constructor will create nested arrays, this one will not), it is also a useful shorthand to convert a function's arguments object into a standard array.
     * @example
     *
     *   Array.create('one', true, 3)   -> ['one', true, 3]
     *   Array.create(['one', true, 3]) -> ['one', true, 3]
     +   Array.create(function(n) {
     *     return arguments;
     *   }('howdy', 'doody'));
     *
     ***/
    'create': function() {
      var result = [];
      multiArgs(arguments, function(a) {
        if(isArgumentsObject(a) || isArrayLike(a)) {
          a = array.prototype.slice.call(a, 0);
        }
        result = result.concat(a);
      });
      return result;
    }

  });

  extend(array, true, false, {

    /***
     * @method find(<f>, [context] = undefined)
     * @returns Mixed
     * @short Returns the first element that matches <f>.
     * @extra [context] is the %this% object if passed. When <f> is a function, will use native implementation if it exists. <f> will also match a string, number, array, object, or alternately test against a function or regex. This method implements @array_matching.
     * @example
     *
     +   [{a:1,b:2},{a:1,b:3},{a:1,b:4}].find(function(n) {
     *     return n['a'] == 1;
     *   });                                  -> {a:1,b:3}
     *   ['cuba','japan','canada'].find(/^c/) -> 'cuba'
     *
     ***/
    'find': function(f, context) {
      checkCallback(f);
      return arrayFind(this, f, 0, false, false, context);
    },

    /***
     * @method findIndex(<f>, [context] = undefined)
     * @returns Number
     * @short Returns the index of the first element that matches <f> or -1 if not found.
     * @extra [context] is the %this% object if passed. When <f> is a function, will use native implementation if it exists. <f> will also match a string, number, array, object, or alternately test against a function or regex. This method implements @array_matching.
     *
     * @example
     *
     +   [1,2,3,4].findIndex(function(n) {
     *     return n % 2 == 0;
     *   }); -> 1
     +   [1,2,3,4].findIndex(3);               -> 2
     +   ['one','two','three'].findIndex(/t/); -> 1
     *
     ***/
    'findIndex': function(f, context) {
      var index;
      checkCallback(f);
      index = arrayFind(this, f, 0, false, true, context);
      return isUndefined(index) ? -1 : index;
    }

  });

  extend(array, true, true, {

    /***
     * @method findFrom(<f>, [index] = 0, [loop] = false)
     * @returns Array
     * @short Returns any element that matches <f>, beginning from [index].
     * @extra <f> will match a string, number, array, object, or alternately test against a function or regex. Will continue from index = 0 if [loop] is true. This method implements @array_matching.
     * @example
     *
     *   ['cuba','japan','canada'].findFrom(/^c/, 2) -> 'canada'
     *
     ***/
    'findFrom': function(f, index, loop) {
      return arrayFind(this, f, index, loop);
    },

    /***
     * @method findIndexFrom(<f>, [index] = 0, [loop] = false)
     * @returns Array
     * @short Returns the index of any element that matches <f>, beginning from [index].
     * @extra <f> will match a string, number, array, object, or alternately test against a function or regex. Will continue from index = 0 if [loop] is true. This method implements @array_matching.
     * @example
     *
     *   ['cuba','japan','canada'].findIndexFrom(/^c/, 2) -> 2
     *
     ***/
    'findIndexFrom': function(f, index, loop) {
      var index = arrayFind(this, f, index, loop, true);
      return isUndefined(index) ? -1 : index;
    },

    /***
     * @method findAll(<f>, [index] = 0, [loop] = false)
     * @returns Array
     * @short Returns all elements that match <f>.
     * @extra <f> will match a string, number, array, object, or alternately test against a function or regex. Starts at [index], and will continue once from index = 0 if [loop] is true. This method implements @array_matching.
     * @example
     *
     +   [{a:1,b:2},{a:1,b:3},{a:2,b:4}].findAll(function(n) {
     *     return n['a'] == 1;
     *   });                                        -> [{a:1,b:3},{a:1,b:4}]
     *   ['cuba','japan','canada'].findAll(/^c/)    -> 'cuba','canada'
     *   ['cuba','japan','canada'].findAll(/^c/, 2) -> 'canada'
     *
     ***/
    'findAll': function(f, index, loop) {
      var result = [], matcher;
      if(this.length > 0) {
        matcher = getMatcher(f);
        arrayEach(this, function(el, i, arr) {
          if(matcher(el, i, arr)) {
            result.push(el);
          }
        }, index, loop);
      }
      return result;
    },

    /***
     * @method count(<f>)
     * @returns Number
     * @short Counts all elements in the array that match <f>.
     * @extra <f> will match a string, number, array, object, or alternately test against a function or regex. This method implements @array_matching.
     * @example
     *
     *   [1,2,3,1].count(1)       -> 2
     *   ['a','b','c'].count(/b/) -> 1
     +   [{a:1},{b:2}].count(function(n) {
     *     return n['a'] > 1;
     *   });                      -> 0
     *
     ***/
    'count': function(f) {
      if(isUndefined(f)) return this.length;
      return this.findAll(f).length;
    },

    /***
     * @method removeAt(<start>, [end])
     * @returns Array
     * @short Removes element at <start>. If [end] is specified, removes the range between <start> and [end]. This method will change the array! If you don't intend the array to be changed use %clone% first.
     * @example
     *
     *   ['a','b','c'].removeAt(0) -> ['b','c']
     *   [1,2,3,4].removeAt(1, 3)  -> [1]
     *
     ***/
    'removeAt': function(start, end) {
      if(isUndefined(start)) return this;
      if(isUndefined(end))   end = start;
      this.splice(start, end - start + 1);
      return this;
    },

    /***
     * @method include(<el>, [index])
     * @returns Array
     * @short Adds <el> to the array.
     * @extra This is a non-destructive alias for %add%. It will not change the original array.
     * @example
     *
     *   [1,2,3,4].include(5)       -> [1,2,3,4,5]
     *   [1,2,3,4].include(8, 1)    -> [1,8,2,3,4]
     *   [1,2,3,4].include([5,6,7]) -> [1,2,3,4,5,6,7]
     *
     ***/
    'include': function(el, index) {
      return this.clone().add(el, index);
    },

    /***
     * @method exclude([f1], [f2], ...)
     * @returns Array
     * @short Removes any element in the array that matches [f1], [f2], etc.
     * @extra This is a non-destructive alias for %remove%. It will not change the original array. This method implements @array_matching.
     * @example
     *
     *   [1,2,3].exclude(3)         -> [1,2]
     *   ['a','b','c'].exclude(/b/) -> ['a','c']
     +   [{a:1},{b:2}].exclude(function(n) {
     *     return n['a'] == 1;
     *   });                       -> [{b:2}]
     *
     ***/
    'exclude': function() {
      return array.prototype.remove.apply(this.clone(), arguments);
    },

    /***
     * @method clone()
     * @returns Array
     * @short Makes a shallow clone of the array.
     * @example
     *
     *   [1,2,3].clone() -> [1,2,3]
     *
     ***/
    'clone': function() {
      return simpleMerge([], this);
    },

    /***
     * @method unique([map] = null)
     * @returns Array
     * @short Removes all duplicate elements in the array.
     * @extra [map] may be a function mapping the value to be uniqued on or a string acting as a shortcut. This is most commonly used when you have a key that ensures the object's uniqueness, and don't need to check all fields. This method will also correctly operate on arrays of objects.
     * @example
     *
     *   [1,2,2,3].unique()                 -> [1,2,3]
     *   [{foo:'bar'},{foo:'bar'}].unique() -> [{foo:'bar'}]
     +   [{foo:'bar'},{foo:'bar'}].unique(function(obj){
     *     return obj.foo;
     *   }); -> [{foo:'bar'}]
     *   [{foo:'bar'},{foo:'bar'}].unique('foo') -> [{foo:'bar'}]
     *
     ***/
    'unique': function(map) {
      return arrayUnique(this, map);
    },

    /***
     * @method flatten([limit] = Infinity)
     * @returns Array
     * @short Returns a flattened, one-dimensional copy of the array.
     * @extra You can optionally specify a [limit], which will only flatten that depth.
     * @example
     *
     *   [[1], 2, [3]].flatten()      -> [1,2,3]
     *   [['a'],[],'b','c'].flatten() -> ['a','b','c']
     *
     ***/
    'flatten': function(limit) {
      return arrayFlatten(this, limit);
    },

    /***
     * @method union([a1], [a2], ...)
     * @returns Array
     * @short Returns an array containing all elements in all arrays with duplicates removed.
     * @extra This method will also correctly operate on arrays of objects.
     * @example
     *
     *   [1,3,5].union([5,7,9])     -> [1,3,5,7,9]
     *   ['a','b'].union(['b','c']) -> ['a','b','c']
     *
     ***/
    'union': function() {
      return arrayUnique(this.concat(flatArguments(arguments)));
    },

    /***
     * @method intersect([a1], [a2], ...)
     * @returns Array
     * @short Returns an array containing the elements all arrays have in common.
     * @extra This method will also correctly operate on arrays of objects.
     * @example
     *
     *   [1,3,5].intersect([5,7,9])   -> [5]
     *   ['a','b'].intersect('b','c') -> ['b']
     *
     ***/
    'intersect': function() {
      return arrayIntersect(this, flatArguments(arguments), false);
    },

    /***
     * @method subtract([a1], [a2], ...)
     * @returns Array
     * @short Subtracts from the array all elements in [a1], [a2], etc.
     * @extra This method will also correctly operate on arrays of objects.
     * @example
     *
     *   [1,3,5].subtract([5,7,9])   -> [1,3]
     *   [1,3,5].subtract([3],[5])   -> [1]
     *   ['a','b'].subtract('b','c') -> ['a']
     *
     ***/
    'subtract': function(a) {
      return arrayIntersect(this, flatArguments(arguments), true);
    },

    /***
     * @method at(<index>, [loop] = true)
     * @returns Mixed
     * @short Gets the element(s) at a given index.
     * @extra When [loop] is true, overshooting the end of the array (or the beginning) will begin counting from the other end. As an alternate syntax, passing multiple indexes will get the elements at those indexes.
     * @example
     *
     *   [1,2,3].at(0)        -> 1
     *   [1,2,3].at(2)        -> 3
     *   [1,2,3].at(4)        -> 2
     *   [1,2,3].at(4, false) -> null
     *   [1,2,3].at(-1)       -> 3
     *   [1,2,3].at(0,1)      -> [1,2]
     *
     ***/
    'at': function() {
      return getEntriesForIndexes(this, arguments);
    },

    /***
     * @method first([num] = 1)
     * @returns Mixed
     * @short Returns the first element(s) in the array.
     * @extra When <num> is passed, returns the first <num> elements in the array.
     * @example
     *
     *   [1,2,3].first()        -> 1
     *   [1,2,3].first(2)       -> [1,2]
     *
     ***/
    'first': function(num) {
      if(isUndefined(num)) return this[0];
      if(num < 0) num = 0;
      return this.slice(0, num);
    },

    /***
     * @method last([num] = 1)
     * @returns Mixed
     * @short Returns the last element(s) in the array.
     * @extra When <num> is passed, returns the last <num> elements in the array.
     * @example
     *
     *   [1,2,3].last()        -> 3
     *   [1,2,3].last(2)       -> [2,3]
     *
     ***/
    'last': function(num) {
      if(isUndefined(num)) return this[this.length - 1];
      var start = this.length - num < 0 ? 0 : this.length - num;
      return this.slice(start);
    },

    /***
     * @method from(<index>)
     * @returns Array
     * @short Returns a slice of the array from <index>.
     * @example
     *
     *   [1,2,3].from(1)  -> [2,3]
     *   [1,2,3].from(2)  -> [3]
     *
     ***/
    'from': function(num) {
      return this.slice(num);
    },

    /***
     * @method to(<index>)
     * @returns Array
     * @short Returns a slice of the array up to <index>.
     * @example
     *
     *   [1,2,3].to(1)  -> [1]
     *   [1,2,3].to(2)  -> [1,2]
     *
     ***/
    'to': function(num) {
      if(isUndefined(num)) num = this.length;
      return this.slice(0, num);
    },

    /***
     * @method min([map], [all] = false)
     * @returns Mixed
     * @short Returns the element in the array with the lowest value.
     * @extra [map] may be a function mapping the value to be checked or a string acting as a shortcut. If [all] is true, will return all min values in an array.
     * @example
     *
     *   [1,2,3].min()                          -> 1
     *   ['fee','fo','fum'].min('length')       -> 'fo'
     *   ['fee','fo','fum'].min('length', true) -> ['fo']
     +   ['fee','fo','fum'].min(function(n) {
     *     return n.length;
     *   });                              -> ['fo']
     +   [{a:3,a:2}].min(function(n) {
     *     return n['a'];
     *   });                              -> [{a:2}]
     *
     ***/
    'min': function(map, all) {
      return getMinOrMax(this, map, 'min', all);
    },

    /***
     * @method max([map], [all] = false)
     * @returns Mixed
     * @short Returns the element in the array with the greatest value.
     * @extra [map] may be a function mapping the value to be checked or a string acting as a shortcut. If [all] is true, will return all max values in an array.
     * @example
     *
     *   [1,2,3].max()                          -> 3
     *   ['fee','fo','fum'].max('length')       -> 'fee'
     *   ['fee','fo','fum'].max('length', true) -> ['fee']
     +   [{a:3,a:2}].max(function(n) {
     *     return n['a'];
     *   });                              -> {a:3}
     *
     ***/
    'max': function(map, all) {
      return getMinOrMax(this, map, 'max', all);
    },

    /***
     * @method least([map])
     * @returns Array
     * @short Returns the elements in the array with the least commonly occuring value.
     * @extra [map] may be a function mapping the value to be checked or a string acting as a shortcut.
     * @example
     *
     *   [3,2,2].least()                   -> [3]
     *   ['fe','fo','fum'].least('length') -> ['fum']
     +   [{age:35,name:'ken'},{age:12,name:'bob'},{age:12,name:'ted'}].least(function(n) {
     *     return n.age;
     *   });                               -> [{age:35,name:'ken'}]
     *
     ***/
    'least': function(map, all) {
      return getMinOrMax(this.groupBy.apply(this, [map]), 'length', 'min', all);
    },

    /***
     * @method most([map])
     * @returns Array
     * @short Returns the elements in the array with the most commonly occuring value.
     * @extra [map] may be a function mapping the value to be checked or a string acting as a shortcut.
     * @example
     *
     *   [3,2,2].most()                   -> [2]
     *   ['fe','fo','fum'].most('length') -> ['fe','fo']
     +   [{age:35,name:'ken'},{age:12,name:'bob'},{age:12,name:'ted'}].most(function(n) {
     *     return n.age;
     *   });                              -> [{age:12,name:'bob'},{age:12,name:'ted'}]
     *
     ***/
    'most': function(map, all) {
      return getMinOrMax(this.groupBy.apply(this, [map]), 'length', 'max', all);
    },

    /***
     * @method sum([map])
     * @returns Number
     * @short Sums all values in the array.
     * @extra [map] may be a function mapping the value to be summed or a string acting as a shortcut.
     * @example
     *
     *   [1,2,2].sum()                           -> 5
     +   [{age:35},{age:12},{age:12}].sum(function(n) {
     *     return n.age;
     *   });                                     -> 59
     *   [{age:35},{age:12},{age:12}].sum('age') -> 59
     *
     ***/
    'sum': function(map) {
      var arr = map ? this.map(map) : this;
      return arr.length > 0 ? arr.reduce(function(a,b) { return a + b; }) : 0;
    },

    /***
     * @method average([map])
     * @returns Number
     * @short Gets the mean average for all values in the array.
     * @extra [map] may be a function mapping the value to be averaged or a string acting as a shortcut.
     * @example
     *
     *   [1,2,3].average()                           -> 2
     +   [{age:35},{age:11},{age:11}].average(function(n) {
     *     return n.age;
     *   });                                         -> 19
     *   [{age:35},{age:11},{age:11}].average('age') -> 19
     *
     ***/
    'average': function(map) {
      var arr = map ? this.map(map) : this;
      return arr.length > 0 ? arr.sum() / arr.length : 0;
    },

    /***
     * @method inGroups(<num>, [padding])
     * @returns Array
     * @short Groups the array into <num> arrays.
     * @extra [padding] specifies a value with which to pad the last array so that they are all equal length.
     * @example
     *
     *   [1,2,3,4,5,6,7].inGroups(3)         -> [ [1,2,3], [4,5,6], [7] ]
     *   [1,2,3,4,5,6,7].inGroups(3, 'none') -> [ [1,2,3], [4,5,6], [7,'none','none'] ]
     *
     ***/
    'inGroups': function(num, padding) {
      var pad = arguments.length > 1;
      var arr = this;
      var result = [];
      var divisor = ceil(this.length / num);
      simpleRepeat(num, function(i) {
        var index = i * divisor;
        var group = arr.slice(index, index + divisor);
        if(pad && group.length < divisor) {
          simpleRepeat(divisor - group.length, function() {
            group = group.add(padding);
          });
        }
        result.push(group);
      });
      return result;
    },

    /***
     * @method inGroupsOf(<num>, [padding] = null)
     * @returns Array
     * @short Groups the array into arrays of <num> elements each.
     * @extra [padding] specifies a value with which to pad the last array so that they are all equal length.
     * @example
     *
     *   [1,2,3,4,5,6,7].inGroupsOf(4)         -> [ [1,2,3,4], [5,6,7] ]
     *   [1,2,3,4,5,6,7].inGroupsOf(4, 'none') -> [ [1,2,3,4], [5,6,7,'none'] ]
     *
     ***/
    'inGroupsOf': function(num, padding) {
      var result = [], len = this.length, arr = this, group;
      if(len === 0 || num === 0) return arr;
      if(isUndefined(num)) num = 1;
      if(isUndefined(padding)) padding = null;
      simpleRepeat(ceil(len / num), function(i) {
        group = arr.slice(num * i, num * i + num);
        while(group.length < num) {
          group.push(padding);
        }
        result.push(group);
      });
      return result;
    },

    /***
     * @method isEmpty()
     * @returns Boolean
     * @short Returns true if the array is empty.
     * @extra This is true if the array has a length of zero, or contains only %undefined%, %null%, or %NaN%.
     * @example
     *
     *   [].isEmpty()               -> true
     *   [null,undefined].isEmpty() -> true
     *
     ***/
    'isEmpty': function() {
      return this.compact().length == 0;
    },

    /***
     * @method sortBy(<map>, [desc] = false)
     * @returns Array
     * @short Sorts the array by <map>.
     * @extra <map> may be a function, a string acting as a shortcut, or blank (direct comparison of array values). [desc] will sort the array in descending order. When the field being sorted on is a string, the resulting order will be determined by an internal collation algorithm that is optimized for major Western languages, but can be customized. For more information see @array_sorting.
     * @example
     *
     *   ['world','a','new'].sortBy('length')       -> ['a','new','world']
     *   ['world','a','new'].sortBy('length', true) -> ['world','new','a']
     +   [{age:72},{age:13},{age:18}].sortBy(function(n) {
     *     return n.age;
     *   });                                        -> [{age:13},{age:18},{age:72}]
     *
     ***/
    'sortBy': function(map, desc) {
      var arr = this.clone();
      arr.sort(function(a, b) {
        var aProperty, bProperty, comp;
        aProperty = transformArgument(a, map, arr, [a]);
        bProperty = transformArgument(b, map, arr, [b]);
        if(isString(aProperty) && isString(bProperty)) {
          comp = collateStrings(aProperty, bProperty);
        } else if(aProperty < bProperty) {
          comp = -1;
        } else if(aProperty > bProperty) {
          comp = 1;
        } else {
          comp = 0;
        }
        return comp * (desc ? -1 : 1);
      });
      return arr;
    },

    /***
     * @method randomize()
     * @returns Array
     * @short Returns a copy of the array with the elements randomized.
     * @extra Uses Fisher-Yates algorithm.
     * @example
     *
     *   [1,2,3,4].randomize()  -> [?,?,?,?]
     *
     ***/
    'randomize': function() {
      var arr = this.concat(), i = arr.length, j, x;
      while(i) {
        j = (math.random() * i) | 0;
        x = arr[--i];
        arr[i] = arr[j];
        arr[j] = x;
      }
      return arr;
    },

    /***
     * @method zip([arr1], [arr2], ...)
     * @returns Array
     * @short Merges multiple arrays together.
     * @extra This method "zips up" smaller arrays into one large whose elements are "all elements at index 0", "all elements at index 1", etc. Useful when you have associated data that is split over separated arrays. If the arrays passed have more elements than the original array, they will be discarded. If they have fewer elements, the missing elements will filled with %null%.
     * @example
     *
     *   [1,2,3].zip([4,5,6])                                       -> [[1,2], [3,4], [5,6]]
     *   ['Martin','John'].zip(['Luther','F.'], ['King','Kennedy']) -> [['Martin','Luther','King'], ['John','F.','Kennedy']]
     *
     ***/
    'zip': function() {
      var args = multiArgs(arguments);
      return this.map(function(el, i) {
        return [el].concat(args.map(function(k) {
          return (i in k) ? k[i] : null;
        }));
      });
    },

    /***
     * @method sample([num])
     * @returns Mixed
     * @short Returns a random element from the array.
     * @extra If [num] is passed, will return [num] samples from the array.
     * @example
     *
     *   [1,2,3,4,5].sample()  -> // Random element
     *   [1,2,3,4,5].sample(3) -> // Array of 3 random elements
     *
     ***/
    'sample': function(num) {
      var arr = this.randomize();
      return arguments.length > 0 ? arr.slice(0, num) : arr[0];
    },

    /***
     * @method each(<fn>, [index] = 0, [loop] = false)
     * @returns Array
     * @short Runs <fn> against each element in the array. Enhanced version of %Array#forEach%.
     * @extra Parameters passed to <fn> are identical to %forEach%, ie. the first parameter is the current element, second parameter is the current index, and third parameter is the array itself. If <fn> returns %false% at any time it will break out of the loop. Once %each% finishes, it will return the array. If [index] is passed, <fn> will begin at that index and work its way to the end. If [loop] is true, it will then start over from the beginning of the array and continue until it reaches [index] - 1.
     * @example
     *
     *   [1,2,3,4].each(function(n) {
     *     // Called 4 times: 1, 2, 3, 4
     *   });
     *   [1,2,3,4].each(function(n) {
     *     // Called 4 times: 3, 4, 1, 2
     *   }, 2, true);
     *
     ***/
    'each': function(fn, index, loop) {
      arrayEach(this, fn, index, loop);
      return this;
    },

    /***
     * @method add(<el>, [index])
     * @returns Array
     * @short Adds <el> to the array.
     * @extra If [index] is specified, it will add at [index], otherwise adds to the end of the array. %add% behaves like %concat% in that if <el> is an array it will be joined, not inserted. This method will change the array! Use %include% for a non-destructive alias. Also, %insert% is provided as an alias that reads better when using an index.
     * @example
     *
     *   [1,2,3,4].add(5)       -> [1,2,3,4,5]
     *   [1,2,3,4].add([5,6,7]) -> [1,2,3,4,5,6,7]
     *   [1,2,3,4].insert(8, 1) -> [1,8,2,3,4]
     *
     ***/
    'add': function(el, index) {
      if(!isNumber(number(index)) || isNaN(index)) index = this.length;
      array.prototype.splice.apply(this, [index, 0].concat(el));
      return this;
    },

    /***
     * @method remove([f1], [f2], ...)
     * @returns Array
     * @short Removes any element in the array that matches [f1], [f2], etc.
     * @extra Will match a string, number, array, object, or alternately test against a function or regex. This method will change the array! Use %exclude% for a non-destructive alias. This method implements @array_matching.
     * @example
     *
     *   [1,2,3].remove(3)         -> [1,2]
     *   ['a','b','c'].remove(/b/) -> ['a','c']
     +   [{a:1},{b:2}].remove(function(n) {
     *     return n['a'] == 1;
     *   });                       -> [{b:2}]
     *
     ***/
    'remove': function() {
      var arr = this;
      multiArgs(arguments, function(f) {
        var i = 0, matcher = getMatcher(f);
        while(i < arr.length) {
          if(matcher(arr[i], i, arr)) {
            arr.splice(i, 1);
          } else {
            i++;
          }
        }
      });
      return arr;
    },

    /***
     * @method compact([all] = false)
     * @returns Array
     * @short Removes all instances of %undefined%, %null%, and %NaN% from the array.
     * @extra If [all] is %true%, all "falsy" elements will be removed. This includes empty strings, 0, and false.
     * @example
     *
     *   [1,null,2,undefined,3].compact() -> [1,2,3]
     *   [1,'',2,false,3].compact()       -> [1,'',2,false,3]
     *   [1,'',2,false,3].compact(true)   -> [1,2,3]
     *
     ***/
    'compact': function(all) {
      var result = [];
      arrayEach(this, function(el, i) {
        if(isArray(el)) {
          result.push(el.compact());
        } else if(all && el) {
          result.push(el);
        } else if(!all && el != null && el.valueOf() === el.valueOf()) {
          result.push(el);
        }
      });
      return result;
    },

    /***
     * @method groupBy(<map>, [fn])
     * @returns Object
     * @short Groups the array by <map>.
     * @extra Will return an object with keys equal to the grouped values. <map> may be a mapping function, or a string acting as a shortcut. Optionally calls [fn] for each group.
     * @example
     *
     *   ['fee','fi','fum'].groupBy('length') -> { 2: ['fi'], 3: ['fee','fum'] }
     +   [{age:35,name:'ken'},{age:15,name:'bob'}].groupBy(function(n) {
     *     return n.age;
     *   });                                  -> { 35: [{age:35,name:'ken'}], 15: [{age:15,name:'bob'}] }
     *
     ***/
    'groupBy': function(map, fn) {
      var arr = this, result = {}, key;
      arrayEach(arr, function(el, index) {
        key = transformArgument(el, map, arr, [el, index, arr]);
        if(!result[key]) result[key] = [];
        result[key].push(el);
      });
      if(fn) {
        iterateOverObject(result, fn);
      }
      return result;
    },

    /***
     * @method none(<f>)
     * @returns Boolean
     * @short Returns true if none of the elements in the array match <f>.
     * @extra <f> will match a string, number, array, object, or alternately test against a function or regex. This method implements @array_matching.
     * @example
     *
     *   [1,2,3].none(5)         -> true
     *   ['a','b','c'].none(/b/) -> false
     +   [{a:1},{b:2}].none(function(n) {
     *     return n['a'] > 1;
     *   });                     -> true
     *
     ***/
    'none': function() {
      return !this.any.apply(this, arguments);
    }


  });


  // Aliases

  extend(array, true, true, {

    /***
     * @method all()
     * @alias every
     *
     ***/
    'all': array.prototype.every,

    /*** @method any()
     * @alias some
     *
     ***/
    'any': array.prototype.some,

    /***
     * @method insert()
     * @alias add
     *
     ***/
    'insert': array.prototype.add

  });


  /***
   * Object module
   * Enumerable methods on objects
   *
   ***/

   function keysWithObjectCoercion(obj) {
     return object.keys(coercePrimitiveToObject(obj));
   }

  /***
   * @method [enumerable](<obj>)
   * @returns Boolean
   * @short Enumerable methods in the Array package are also available to the Object class. They will perform their normal operations for every property in <obj>.
   * @extra In cases where a callback is used, instead of %element, index%, the callback will instead be passed %key, value%. Enumerable methods are also available to extended objects as instance methods.
   *
   * @set
   *   each
   *   map
   *   any
   *   all
   *   none
   *   count
   *   find
   *   findAll
   *   reduce
   *   isEmpty
   *   sum
   *   average
   *   min
   *   max
   *   least
   *   most
   *
   * @example
   *
   *   Object.any({foo:'bar'}, 'bar')            -> true
   *   Object.extended({foo:'bar'}).any('bar')   -> true
   *   Object.isEmpty({})                        -> true
   +   Object.map({ fred: { age: 52 } }, 'age'); -> { fred: 52 }
   *
   ***/

  function buildEnumerableMethods(names, mapping) {
    extendSimilar(object, false, true, names, function(methods, name) {
      methods[name] = function(obj, arg1, arg2) {
        var result, coerced = keysWithObjectCoercion(obj), matcher;
        if(!mapping) {
          matcher = getMatcher(arg1, true);
        }
        result = array.prototype[name].call(coerced, function(key) {
          var value = obj[key];
          if(mapping) {
            return transformArgument(value, arg1, obj, [key, value, obj]);
          } else {
            return matcher(value, key, obj);
          }
        }, arg2);
        if(isArray(result)) {
          // The method has returned an array of keys so use this array
          // to build up the resulting object in the form we want it in.
          result = result.reduce(function(o, key, i) {
            o[key] = obj[key];
            return o;
          }, {});
        }
        return result;
      };
    });
    buildObjectInstanceMethods(names, Hash);
  }

  function exportSortAlgorithm() {
    array[AlphanumericSort] = collateStrings;
  }

  extend(object, false, true, {

    'map': function(obj, map) {
      var result = {}, key, value;
      for(key in obj) {
        if(!hasOwnProperty(obj, key)) continue;
        value = obj[key];
        result[key] = transformArgument(value, map, obj, [key, value, obj]);
      }
      return result;
    },

    'reduce': function(obj) {
      var values = keysWithObjectCoercion(obj).map(function(key) {
        return obj[key];
      });
      return values.reduce.apply(values, multiArgs(arguments, null, 1));
    },

    'each': function(obj, fn) {
      checkCallback(fn);
      iterateOverObject(obj, fn);
      return obj;
    },

    /***
     * @method size(<obj>)
     * @returns Number
     * @short Returns the number of properties in <obj>.
     * @extra %size% is available as an instance method on extended objects.
     * @example
     *
     *   Object.size({ foo: 'bar' }) -> 1
     *
     ***/
    'size': function (obj) {
      return keysWithObjectCoercion(obj).length;
    }

  });

  var EnumerableFindingMethods = 'any,all,none,count,find,findAll,isEmpty'.split(',');
  var EnumerableMappingMethods = 'sum,average,min,max,least,most'.split(',');
  var EnumerableOtherMethods   = 'map,reduce,size'.split(',');
  var EnumerableMethods        = EnumerableFindingMethods.concat(EnumerableMappingMethods).concat(EnumerableOtherMethods);

  buildEnhancements();
  buildAlphanumericSort();
  buildEnumerableMethods(EnumerableFindingMethods);
  buildEnumerableMethods(EnumerableMappingMethods, true);
  buildObjectInstanceMethods(EnumerableOtherMethods, Hash);
  exportSortAlgorithm();


  /***
   * @package Function
   * @dependency core
   * @description Lazy, throttled, and memoized functions, delayed functions and handling of timers, argument currying.
   *
   ***/

  function setDelay(fn, ms, after, scope, args) {
    // Delay of infinity is never called of course...
    if(ms === Infinity) return;
    if(!fn.timers) fn.timers = [];
    if(!isNumber(ms)) ms = 1;
    // This is a workaround for <= IE8, which apparently has the
    // ability to call timeouts in the queue on the same tick (ms?)
    // even if functionally they have already been cleared.
    fn._canceled = false;
    fn.timers.push(setTimeout(function(){
      if(!fn._canceled) {
        after.apply(scope, args || []);
      }
    }, ms));
  }

  extend(Function, true, true, {

     /***
     * @method lazy([ms] = 1, [immediate] = false, [limit] = Infinity)
     * @returns Function
     * @short Creates a lazy function that, when called repeatedly, will queue execution and wait [ms] milliseconds to execute.
     * @extra If [immediate] is %true%, first execution will happen immediately, then lock. If [limit] is a fininte number, calls past [limit] will be ignored while execution is locked. Compare this to %throttle%, which will execute only once per [ms] milliseconds. Note that [ms] can also be a fraction. Calling %cancel% on a lazy function will clear the entire queue. For more see @functions.
     * @example
     *
     *   (function() {
     *     // Executes immediately.
     *   }).lazy()();
     *   (3).times(function() {
     *     // Executes 3 times, with each execution 20ms later than the last.
     *   }.lazy(20));
     *   (100).times(function() {
     *     // Executes 50 times, with each execution 20ms later than the last.
     *   }.lazy(20, false, 50));
     *
     ***/
    'lazy': function(ms, immediate, limit) {
      var fn = this, queue = [], locked = false, execute, rounded, perExecution, result;
      ms = ms || 1;
      limit = limit || Infinity;
      rounded = ceil(ms);
      perExecution = round(rounded / ms) || 1;
      execute = function() {
        var queueLength = queue.length, maxPerRound;
        if(queueLength == 0) return;
        // Allow fractions of a millisecond by calling
        // multiple times per actual timeout execution
        maxPerRound = max(queueLength - perExecution, 0);
        while(queueLength > maxPerRound) {
          // Getting uber-meta here...
          result = Function.prototype.apply.apply(fn, queue.shift());
          queueLength--;
        }
        setDelay(lazy, rounded, function() {
          locked = false;
          execute();
        });
      }
      function lazy() {
        // If the execution has locked and it's immediate, then
        // allow 1 less in the queue as 1 call has already taken place.
        if(queue.length < limit - (locked && immediate ? 1 : 0)) {
          queue.push([this, arguments]);
        }
        if(!locked) {
          locked = true;
          if(immediate) {
            execute();
          } else {
            setDelay(lazy, rounded, execute);
          }
        }
        // Return the memoized result
        return result;
      }
      return lazy;
    },

     /***
     * @method throttle([ms] = 1)
     * @returns Function
     * @short Creates a "throttled" version of the function that will only be executed once per <ms> milliseconds.
     * @extra This is functionally equivalent to calling %lazy% with a [limit] of %1% and [immediate] as %true%. %throttle% is appropriate when you want to make sure a function is only executed at most once for a given duration. For more see @functions.
     * @example
     *
     *   (3).times(function() {
     *     // called only once. will wait 50ms until it responds again
     *   }.throttle(50));
     *
     ***/
    'throttle': function(ms) {
      return this.lazy(ms, true, 1);
    },

     /***
     * @method debounce([ms] = 1)
     * @returns Function
     * @short Creates a "debounced" function that postpones its execution until after <ms> milliseconds have passed.
     * @extra This method is useful to execute a function after things have "settled down". A good example of this is when a user tabs quickly through form fields, execution of a heavy operation should happen after a few milliseconds when they have "settled" on a field. For more see @functions.
     * @example
     *
     *   var fn = (function(arg1) {
     *     // called once 50ms later
     *   }).debounce(50); fn() fn() fn();
     *
     ***/
    'debounce': function(ms) {
      var fn = this;
      function debounced() {
        debounced.cancel();
        setDelay(debounced, ms, fn, this, arguments);
      };
      return debounced;
    },

     /***
     * @method delay([ms] = 1, [arg1], ...)
     * @returns Function
     * @short Executes the function after <ms> milliseconds.
     * @extra Returns a reference to itself. %delay% is also a way to execute non-blocking operations that will wait until the CPU is free. Delayed functions can be canceled using the %cancel% method. Can also curry arguments passed in after <ms>.
     * @example
     *
     *   (function(arg1) {
     *     // called 1s later
     *   }).delay(1000, 'arg1');
     *
     ***/
    'delay': function(ms) {
      var fn = this;
      var args = multiArgs(arguments, null, 1);
      setDelay(fn, ms, fn, fn, args);
      return fn;
    },

     /***
     * @method every([ms] = 1, [arg1], ...)
     * @returns Function
     * @short Executes the function every <ms> milliseconds.
     * @extra Returns a reference to itself. Repeating functions with %every% can be canceled using the %cancel% method. Can also curry arguments passed in after <ms>.
     * @example
     *
     *   (function(arg1) {
     *     // called every 1s
     *   }).every(1000, 'arg1');
     *
     ***/
    'every': function(ms) {
      var fn = this, args = arguments;
      args = args.length > 1 ? multiArgs(args, null, 1) : [];
      function execute () {
        fn.apply(fn, args);
        setDelay(fn, ms, execute);
      }
      setDelay(fn, ms, execute);
      return fn;
    },

     /***
     * @method cancel()
     * @returns Function
     * @short Cancels a delayed function scheduled to be run.
     * @extra %delay%, %lazy%, %throttle%, and %debounce% can all set delays.
     * @example
     *
     *   (function() {
     *     alert('hay'); // Never called
     *   }).delay(500).cancel();
     *
     ***/
    'cancel': function() {
      var timers = this.timers, timer;
      if(isArray(timers)) {
        while(timer = timers.shift()) {
          clearTimeout(timer);
        }
      }
      this._canceled = true;
      return this;
    },

     /***
     * @method after([num] = 1)
     * @returns Function
     * @short Creates a function that will execute after [num] calls.
     * @extra %after% is useful for running a final callback after a series of asynchronous operations, when the order in which the operations will complete is unknown.
     * @example
     *
     *   var fn = (function() {
     *     // Will be executed once only
     *   }).after(3); fn(); fn(); fn();
     *
     ***/
    'after': function(num) {
      var fn = this, counter = 0, storedArguments = [];
      if(!isNumber(num)) {
        num = 1;
      } else if(num === 0) {
        fn.call();
        return fn;
      }
      return function() {
        var ret;
        storedArguments.push(multiArgs(arguments));
        counter++;
        if(counter == num) {
          ret = fn.call(this, storedArguments);
          counter = 0;
          storedArguments = [];
          return ret;
        }
      }
    },

     /***
     * @method once()
     * @returns Function
     * @short Creates a function that will execute only once and store the result.
     * @extra %once% is useful for creating functions that will cache the result of an expensive operation and use it on subsequent calls. Also it can be useful for creating initialization functions that only need to be run once.
     * @example
     *
     *   var fn = (function() {
     *     // Will be executed once only
     *   }).once(); fn(); fn(); fn();
     *
     ***/
    'once': function() {
      return this.throttle(Infinity, true);
    },

     /***
     * @method fill(<arg1>, <arg2>, ...)
     * @returns Function
     * @short Returns a new version of the function which when called will have some of its arguments pre-emptively filled in, also known as "currying".
     * @extra Arguments passed to a "filled" function are generally appended to the curried arguments. However, if %undefined% is passed as any of the arguments to %fill%, it will be replaced, when the "filled" function is executed. This allows currying of arguments even when they occur toward the end of an argument list (the example demonstrates this much more clearly).
     * @example
     *
     *   var delayOneSecond = setTimeout.fill(undefined, 1000);
     *   delayOneSecond(function() {
     *     // Will be executed 1s later
     *   });
     *
     ***/
    'fill': function() {
      var fn = this, curried = multiArgs(arguments);
      return function() {
        var args = multiArgs(arguments);
        curried.forEach(function(arg, index) {
          if(arg != null || index >= args.length) args.splice(index, 0, arg);
        });
        return fn.apply(this, args);
      }
    }


  });


  /***
   * @package Number
   * @dependency core
   * @description Number formatting, rounding (with precision), and ranges. Aliases to Math methods.
   *
   ***/


  function abbreviateNumber(num, roundTo, str, mid, limit, bytes) {
    var fixed        = num.toFixed(20),
        decimalPlace = fixed.search(/\./),
        numeralPlace = fixed.search(/[1-9]/),
        significant  = decimalPlace - numeralPlace,
        unit, i, divisor;
    if(significant > 0) {
      significant -= 1;
    }
    i = max(min(floor(significant / 3), limit === false ? str.length : limit), -mid);
    unit = str.charAt(i + mid - 1);
    if(significant < -9) {
      i = -3;
      roundTo = abs(significant) - 9;
      unit = str.slice(0,1);
    }
    divisor = bytes ? pow(2, 10 * i) : pow(10, i * 3);
    return withPrecision(num / divisor, roundTo || 0).format() + unit.trim();
  }


  extend(number, false, true, {

    /***
     * @method Number.random([n1], [n2])
     * @returns Number
     * @short Returns a random integer between [n1] and [n2].
     * @extra If only 1 number is passed, the other will be 0. If none are passed, the number will be either 0 or 1.
     * @example
     *
     *   Number.random(50, 100) -> ex. 85
     *   Number.random(50)      -> ex. 27
     *   Number.random()        -> ex. 0
     *
     ***/
    'random': function(n1, n2) {
      var minNum, maxNum;
      if(arguments.length == 1) n2 = n1, n1 = 0;
      minNum = min(n1 || 0, isUndefined(n2) ? 1 : n2);
      maxNum = max(n1 || 0, isUndefined(n2) ? 1 : n2) + 1;
      return floor((math.random() * (maxNum - minNum)) + minNum);
    }

  });

  extend(number, true, true, {

    /***
     * @method log(<base> = Math.E)
     * @returns Number
     * @short Returns the logarithm of the number with base <base>, or natural logarithm of the number if <base> is undefined.
     * @example
     *
     *   (64).log(2) -> 6
     *   (9).log(3)  -> 2
     *   (5).log()   -> 1.6094379124341003
     *
     ***/

    'log': function(base) {
       return math.log(this) / (base ? math.log(base) : 1);
     },

    /***
     * @method abbr([precision] = 0)
     * @returns String
     * @short Returns an abbreviated form of the number.
     * @extra [precision] will round to the given precision.
     * @example
     *
     *   (1000).abbr()    -> "1k"
     *   (1000000).abbr() -> "1m"
     *   (1280).abbr(1)   -> "1.3k"
     *
     ***/
    'abbr': function(precision) {
      return abbreviateNumber(this, precision, 'kmbt', 0, 4);
    },

    /***
     * @method metric([precision] = 0, [limit] = 1)
     * @returns String
     * @short Returns the number as a string in metric notation.
     * @extra [precision] will round to the given precision. Both very large numbers and very small numbers are supported. [limit] is the upper limit for the units. The default is %1%, which is "kilo". If [limit] is %false%, the upper limit will be "exa". The lower limit is "nano", and cannot be changed.
     * @example
     *
     *   (1000).metric()            -> "1k"
     *   (1000000).metric()         -> "1,000k"
     *   (1000000).metric(0, false) -> "1M"
     *   (1249).metric(2) + 'g'     -> "1.25kg"
     *   (0.025).metric() + 'm'     -> "25mm"
     *
     ***/
    'metric': function(precision, limit) {
      return abbreviateNumber(this, precision, 'nμm kMGTPE', 4, isUndefined(limit) ? 1 : limit);
    },

    /***
     * @method bytes([precision] = 0, [limit] = 4)
     * @returns String
     * @short Returns an abbreviated form of the number, considered to be "Bytes".
     * @extra [precision] will round to the given precision. [limit] is the upper limit for the units. The default is %4%, which is "terabytes" (TB). If [limit] is %false%, the upper limit will be "exa".
     * @example
     *
     *   (1000).bytes()                 -> "1kB"
     *   (1000).bytes(2)                -> "0.98kB"
     *   ((10).pow(20)).bytes()         -> "90,949,470TB"
     *   ((10).pow(20)).bytes(0, false) -> "87EB"
     *
     ***/
    'bytes': function(precision, limit) {
      return abbreviateNumber(this, precision, 'kMGTPE', 0, isUndefined(limit) ? 4 : limit, true) + 'B';
    },

    /***
     * @method isInteger()
     * @returns Boolean
     * @short Returns true if the number has no trailing decimal.
     * @example
     *
     *   (420).isInteger() -> true
     *   (4.5).isInteger() -> false
     *
     ***/
    'isInteger': function() {
      return this % 1 == 0;
    },

    /***
     * @method isOdd()
     * @returns Boolean
     * @short Returns true if the number is odd.
     * @example
     *
     *   (3).isOdd()  -> true
     *   (18).isOdd() -> false
     *
     ***/
    'isOdd': function() {
      return !isNaN(this) && !this.isMultipleOf(2);
    },

    /***
     * @method isEven()
     * @returns Boolean
     * @short Returns true if the number is even.
     * @example
     *
     *   (6).isEven()  -> true
     *   (17).isEven() -> false
     *
     ***/
    'isEven': function() {
      return this.isMultipleOf(2);
    },

    /***
     * @method isMultipleOf(<num>)
     * @returns Boolean
     * @short Returns true if the number is a multiple of <num>.
     * @example
     *
     *   (6).isMultipleOf(2)  -> true
     *   (17).isMultipleOf(2) -> false
     *   (32).isMultipleOf(4) -> true
     *   (34).isMultipleOf(4) -> false
     *
     ***/
    'isMultipleOf': function(num) {
      return this % num === 0;
    },


    /***
     * @method format([place] = 0, [thousands] = ',', [decimal] = '.')
     * @returns String
     * @short Formats the number to a readable string.
     * @extra If [place] is %undefined%, will automatically determine the place. [thousands] is the character used for the thousands separator. [decimal] is the character used for the decimal point.
     * @example
     *
     *   (56782).format()           -> '56,782'
     *   (56782).format(2)          -> '56,782.00'
     *   (4388.43).format(2, ' ')      -> '4 388.43'
     *   (4388.43).format(2, '.', ',') -> '4.388,43'
     *
     ***/
    'format': function(place, thousands, decimal) {
      var i, str, split, integer, fraction, result = '';
      if(isUndefined(thousands)) {
        thousands = ',';
      }
      if(isUndefined(decimal)) {
        decimal = '.';
      }
      str      = (isNumber(place) ? withPrecision(this, place || 0).toFixed(max(place, 0)) : this.toString()).replace(/^-/, '');
      split    = str.split('.');
      integer  = split[0];
      fraction = split[1];
      for(i = integer.length; i > 0; i -= 3) {
        if(i < integer.length) {
          result = thousands + result;
        }
        result = integer.slice(max(0, i - 3), i) + result;
      }
      if(fraction) {
        result += decimal + repeatString('0', (place || 0) - fraction.length) + fraction;
      }
      return (this < 0 ? '-' : '') + result;
    },

    /***
     * @method hex([pad] = 1)
     * @returns String
     * @short Converts the number to hexidecimal.
     * @extra [pad] will pad the resulting string to that many places.
     * @example
     *
     *   (255).hex()   -> 'ff';
     *   (255).hex(4)  -> '00ff';
     *   (23654).hex() -> '5c66';
     *
     ***/
    'hex': function(pad) {
      return this.pad(pad || 1, false, 16);
    },

    /***
     * @method times(<fn>)
     * @returns Number
     * @short Calls <fn> a number of times equivalent to the number.
     * @example
     *
     *   (8).times(function(i) {
     *     // This function is called 8 times.
     *   });
     *
     ***/
    'times': function(fn) {
      if(fn) {
        for(var i = 0; i < this; i++) {
          fn.call(this, i);
        }
      }
      return this.toNumber();
    },

    /***
     * @method chr()
     * @returns String
     * @short Returns a string at the code point of the number.
     * @example
     *
     *   (65).chr() -> "A"
     *   (75).chr() -> "K"
     *
     ***/
    'chr': function() {
      return string.fromCharCode(this);
    },

    /***
     * @method pad(<place> = 0, [sign] = false, [base] = 10)
     * @returns String
     * @short Pads a number with "0" to <place>.
     * @extra [sign] allows you to force the sign as well (+05, etc). [base] can change the base for numeral conversion.
     * @example
     *
     *   (5).pad(2)        -> '05'
     *   (-5).pad(4)       -> '-0005'
     *   (82).pad(3, true) -> '+082'
     *
     ***/
    'pad': function(place, sign, base) {
      return padNumber(this, place, sign, base);
    },

    /***
     * @method ordinalize()
     * @returns String
     * @short Returns an ordinalized (English) string, i.e. "1st", "2nd", etc.
     * @example
     *
     *   (1).ordinalize() -> '1st';
     *   (2).ordinalize() -> '2nd';
     *   (8).ordinalize() -> '8th';
     *
     ***/
    'ordinalize': function() {
      var suffix, num = abs(this), last = parseInt(num.toString().slice(-2));
      return this + getOrdinalizedSuffix(last);
    },

    /***
     * @method toNumber()
     * @returns Number
     * @short Returns a number. This is mostly for compatibility reasons.
     * @example
     *
     *   (420).toNumber() -> 420
     *
     ***/
    'toNumber': function() {
      return parseFloat(this, 10);
    }

  });

  /***
   * @method round(<precision> = 0)
   * @returns Number
   * @short Shortcut for %Math.round% that also allows a <precision>.
   *
   * @example
   *
   *   (3.241).round()  -> 3
   *   (-3.841).round() -> -4
   *   (3.241).round(2) -> 3.24
   *   (3748).round(-2) -> 3800
   *
   ***
   * @method ceil(<precision> = 0)
   * @returns Number
   * @short Shortcut for %Math.ceil% that also allows a <precision>.
   *
   * @example
   *
   *   (3.241).ceil()  -> 4
   *   (-3.241).ceil() -> -3
   *   (3.241).ceil(2) -> 3.25
   *   (3748).ceil(-2) -> 3800
   *
   ***
   * @method floor(<precision> = 0)
   * @returns Number
   * @short Shortcut for %Math.floor% that also allows a <precision>.
   *
   * @example
   *
   *   (3.241).floor()  -> 3
   *   (-3.841).floor() -> -4
   *   (3.241).floor(2) -> 3.24
   *   (3748).floor(-2) -> 3700
   *
   ***
   * @method [math]()
   * @returns Number
   * @short Math related functions are mapped as shortcuts to numbers and are identical. Note that %Number#log% provides some special defaults.
   *
   * @set
   *   abs
   *   sin
   *   asin
   *   cos
   *   acos
   *   tan
   *   atan
   *   sqrt
   *   exp
   *   pow
   *
   * @example
   *
   *   (3).pow(3) -> 27
   *   (-3).abs() -> 3
   *   (1024).sqrt() -> 32
   *
   ***/

  function buildNumber() {
    function createRoundingFunction(fn) {
      return function (precision) {
        return precision ? withPrecision(this, precision, fn) : fn(this);
      }
    }
    extend(number, true, true, {
      'ceil':   createRoundingFunction(ceil),
      'round':  createRoundingFunction(round),
      'floor':  createRoundingFunction(floor)
    });
    extendSimilar(number, true, true, 'abs,pow,sin,asin,cos,acos,tan,atan,exp,pow,sqrt', function(methods, name) {
      methods[name] = function(a, b) {
        return math[name](this, a, b);
      }
    });
  }

  buildNumber();


  /***
   * @package Object
   * @dependency core
   * @description Object manipulation, type checking (isNumber, isString, ...), extended objects with hash-like methods available as instance methods.
   *
   * Much thanks to kangax for his informative aricle about how problems with instanceof and constructor
   * http://perfectionkills.com/instanceof-considered-harmful-or-how-to-write-a-robust-isarray/
   *
   ***/

  var ObjectTypeMethods = 'isObject,isNaN'.split(',');
  var ObjectHashMethods = 'keys,values,select,reject,each,merge,clone,equal,watch,tap,has,toQueryString'.split(',');

  function setParamsObject(obj, param, value, castBoolean) {
    var reg = /^(.+?)(\[.*\])$/, paramIsArray, match, allKeys, key;
    if(match = param.match(reg)) {
      key = match[1];
      allKeys = match[2].replace(/^\[|\]$/g, '').split('][');
      allKeys.forEach(function(k) {
        paramIsArray = !k || k.match(/^\d+$/);
        if(!key && isArray(obj)) key = obj.length;
        if(!hasOwnProperty(obj, key)) {
          obj[key] = paramIsArray ? [] : {};
        }
        obj = obj[key];
        key = k;
      });
      if(!key && paramIsArray) key = obj.length.toString();
      setParamsObject(obj, key, value, castBoolean);
    } else if(castBoolean && value === 'true') {
      obj[param] = true;
    } else if(castBoolean && value === 'false') {
      obj[param] = false;
    } else {
      obj[param] = value;
    }
  }

  function objectToQueryString(base, obj) {
    var tmp;
    // If a custom toString exists bail here and use that instead
    if(isArray(obj) || (isObjectType(obj) && obj.toString === internalToString)) {
      tmp = [];
      iterateOverObject(obj, function(key, value) {
        if(base) {
          key = base + '[' + key + ']';
        }
        tmp.push(objectToQueryString(key, value));
      });
      return tmp.join('&');
    } else {
      if(!base) return '';
      return sanitizeURIComponent(base) + '=' + (isDate(obj) ? obj.getTime() : sanitizeURIComponent(obj));
    }
  }

  function sanitizeURIComponent(obj) {
    // undefined, null, and NaN are represented as a blank string,
    // while false and 0 are stringified. "+" is allowed in query string
    return !obj && obj !== false && obj !== 0 ? '' : encodeURIComponent(obj).replace(/%20/g, '+');
  }

  function matchInObject(match, key, value) {
    if(isRegExp(match)) {
      return match.test(key);
    } else if(isObjectType(match)) {
      return match[key] === value;
    } else {
      return key === string(match);
    }
  }

  function selectFromObject(obj, args, select) {
    var match, result = obj instanceof Hash ? new Hash : {};
    iterateOverObject(obj, function(key, value) {
      match = false;
      flattenedArgs(args, function(arg) {
        if(matchInObject(arg, key, value)) {
          match = true;
        }
      }, 1);
      if(match === select) {
        result[key] = value;
      }
    });
    return result;
  }


  /***
   * @method Object.is[Type](<obj>)
   * @returns Boolean
   * @short Returns true if <obj> is an object of that type.
   * @extra %isObject% will return false on anything that is not an object literal, including instances of inherited classes. Note also that %isNaN% will ONLY return true if the object IS %NaN%. It does not mean the same as browser native %isNaN%, which returns true for anything that is "not a number".
   *
   * @set
   *   isArray
   *   isObject
   *   isBoolean
   *   isDate
   *   isFunction
   *   isNaN
   *   isNumber
   *   isString
   *   isRegExp
   *
   * @example
   *
   *   Object.isArray([1,2,3])            -> true
   *   Object.isDate(3)                   -> false
   *   Object.isRegExp(/wasabi/)          -> true
   *   Object.isObject({ broken:'wear' }) -> true
   *
   ***/
  function buildTypeMethods() {
    extendSimilar(object, false, true, ClassNames, function(methods, name) {
      var method = 'is' + name;
      ObjectTypeMethods.push(method);
      methods[method] = typeChecks[name];
    });
  }

  function buildObjectExtend() {
    extend(object, false, function(){ return arguments.length === 0; }, {
      'extend': function() {
        var methods = ObjectTypeMethods.concat(ObjectHashMethods)
        if(typeof EnumerableMethods !== 'undefined') {
          methods = methods.concat(EnumerableMethods);
        }
        buildObjectInstanceMethods(methods, object);
      }
    });
  }

  extend(object, false, true, {
      /***
       * @method watch(<obj>, <prop>, <fn>)
       * @returns Nothing
       * @short Watches a property of <obj> and runs <fn> when it changes.
       * @extra <fn> is passed three arguments: the property <prop>, the old value, and the new value. The return value of [fn] will be set as the new value. This method is useful for things such as validating or cleaning the value when it is set. Warning: this method WILL NOT work in browsers that don't support %Object.defineProperty% (IE 8 and below). This is the only method in Sugar that is not fully compatible with all browsers. %watch% is available as an instance method on extended objects.
       * @example
       *
       *   Object.watch({ foo: 'bar' }, 'foo', function(prop, oldVal, newVal) {
       *     // Will be run when the property 'foo' is set on the object.
       *   });
       *   Object.extended().watch({ foo: 'bar' }, 'foo', function(prop, oldVal, newVal) {
       *     // Will be run when the property 'foo' is set on the object.
       *   });
       *
       ***/
    'watch': function(obj, prop, fn) {
      if(!definePropertySupport) return;
      var value = obj[prop];
      object.defineProperty(obj, prop, {
        'enumerable'  : true,
        'configurable': true,
        'get': function() {
          return value;
        },
        'set': function(to) {
          value = fn.call(obj, prop, value, to);
        }
      });
    }
  });

  extend(object, false, function() { return arguments.length > 1; }, {

    /***
     * @method keys(<obj>, [fn])
     * @returns Array
     * @short Returns an array containing the keys in <obj>. Optionally calls [fn] for each key.
     * @extra This method is provided for browsers that don't support it natively, and additionally is enhanced to accept the callback [fn]. Returned keys are in no particular order. %keys% is available as an instance method on extended objects.
     * @example
     *
     *   Object.keys({ broken: 'wear' }) -> ['broken']
     *   Object.keys({ broken: 'wear' }, function(key, value) {
     *     // Called once for each key.
     *   });
     *   Object.extended({ broken: 'wear' }).keys() -> ['broken']
     *
     ***/
    'keys': function(obj, fn) {
      var keys = object.keys(obj);
      keys.forEach(function(key) {
        fn.call(obj, key, obj[key]);
      });
      return keys;
    }

  });

  extend(object, false, true, {

    'isObject': function(obj) {
      return isPlainObject(obj);
    },

    'isNaN': function(obj) {
      // This is only true of NaN
      return isNumber(obj) && obj.valueOf() !== obj.valueOf();
    },

    /***
     * @method equal(<a>, <b>)
     * @returns Boolean
     * @short Returns true if <a> and <b> are equal.
     * @extra %equal% in Sugar is "egal", meaning the values are equal if they are "not observably distinguishable". Note that on extended objects the name is %equals% for readability.
     * @example
     *
     *   Object.equal({a:2}, {a:2}) -> true
     *   Object.equal({a:2}, {a:3}) -> false
     *   Object.extended({a:2}).equals({a:3}) -> false
     *
     ***/
    'equal': function(a, b) {
      return isEqual(a, b);
    },

    /***
     * @method Object.extended(<obj> = {})
     * @returns Extended object
     * @short Creates a new object, equivalent to %new Object()% or %{}%, but with extended methods.
     * @extra See extended objects for more.
     * @example
     *
     *   Object.extended()
     *   Object.extended({ happy:true, pappy:false }).keys() -> ['happy','pappy']
     *   Object.extended({ happy:true, pappy:false }).values() -> [true, false]
     *
     ***/
    'extended': function(obj) {
      return new Hash(obj);
    },

    /***
     * @method merge(<target>, <source>, [deep] = false, [resolve] = true)
     * @returns Merged object
     * @short Merges all the properties of <source> into <target>.
     * @extra Merges are shallow unless [deep] is %true%. Properties of <source> will win in the case of conflicts, unless [resolve] is %false%. [resolve] can also be a function that resolves the conflict. In this case it will be passed 3 arguments, %key%, %targetVal%, and %sourceVal%, with the context set to <source>. This will allow you to solve conflict any way you want, ie. adding two numbers together, etc. %merge% is available as an instance method on extended objects.
     * @example
     *
     *   Object.merge({a:1},{b:2}) -> { a:1, b:2 }
     *   Object.merge({a:1},{a:2}, false, false) -> { a:1 }
     +   Object.merge({a:1},{a:2}, false, function(key, a, b) {
     *     return a + b;
     *   }); -> { a:3 }
     *   Object.extended({a:1}).merge({b:2}) -> { a:1, b:2 }
     *
     ***/
    'merge': function(target, source, deep, resolve) {
      var key, sourceIsObject, targetIsObject, sourceVal, targetVal, conflict, result;
      // Strings cannot be reliably merged thanks to
      // their properties not being enumerable in < IE8.
      if(target && typeof source !== 'string') {
        for(key in source) {
          if(!hasOwnProperty(source, key) || !target) continue;
          sourceVal      = source[key];
          targetVal      = target[key];
          conflict       = isDefined(targetVal);
          sourceIsObject = isObjectType(sourceVal);
          targetIsObject = isObjectType(targetVal);
          result         = conflict && resolve === false ? targetVal : sourceVal;

          if(conflict) {
            if(isFunction(resolve)) {
              // Use the result of the callback as the result.
              result = resolve.call(source, key, targetVal, sourceVal)
            }
          }

          // Going deep
          if(deep && (sourceIsObject || targetIsObject)) {
            if(isDate(sourceVal)) {
              result = new date(sourceVal.getTime());
            } else if(isRegExp(sourceVal)) {
              result = new regexp(sourceVal.source, getRegExpFlags(sourceVal));
            } else {
              if(!targetIsObject) target[key] = array.isArray(sourceVal) ? [] : {};
              object.merge(target[key], sourceVal, deep, resolve);
              continue;
            }
          }
          target[key] = result;
        }
      }
      return target;
    },

    /***
     * @method values(<obj>, [fn])
     * @returns Array
     * @short Returns an array containing the values in <obj>. Optionally calls [fn] for each value.
     * @extra Returned values are in no particular order. %values% is available as an instance method on extended objects.
     * @example
     *
     *   Object.values({ broken: 'wear' }) -> ['wear']
     *   Object.values({ broken: 'wear' }, function(value) {
     *     // Called once for each value.
     *   });
     *   Object.extended({ broken: 'wear' }).values() -> ['wear']
     *
     ***/
    'values': function(obj, fn) {
      var values = [];
      iterateOverObject(obj, function(k,v) {
        values.push(v);
        if(fn) fn.call(obj,v);
      });
      return values;
    },

    /***
     * @method clone(<obj> = {}, [deep] = false)
     * @returns Cloned object
     * @short Creates a clone (copy) of <obj>.
     * @extra Default is a shallow clone, unless [deep] is true. %clone% is available as an instance method on extended objects.
     * @example
     *
     *   Object.clone({foo:'bar'})            -> { foo: 'bar' }
     *   Object.clone()                       -> {}
     *   Object.extended({foo:'bar'}).clone() -> { foo: 'bar' }
     *
     ***/
    'clone': function(obj, deep) {
      var target, klass;
      if(!isObjectType(obj)) {
        return obj;
      }
      klass = className(obj);
      if(isDate(obj, klass) && obj.clone) {
        // Preserve internal UTC flag when applicable.
        return obj.clone();
      } else if(isDate(obj, klass) || isRegExp(obj, klass)) {
        return new obj.constructor(obj);
      } else if(obj instanceof Hash) {
        target = new Hash;
      } else if(isArray(obj, klass)) {
        target = [];
      } else if(isPlainObject(obj, klass)) {
        target = {};
      } else {
        throw new TypeError('Clone must be a basic data type.');
      }
      return object.merge(target, obj, deep);
    },

    /***
     * @method Object.fromQueryString(<str>, [booleans] = false)
     * @returns Object
     * @short Converts the query string of a URL into an object.
     * @extra If [booleans] is true, then %"true"% and %"false"% will be cast into booleans. All other values, including numbers will remain their string values.
     * @example
     *
     *   Object.fromQueryString('foo=bar&broken=wear') -> { foo: 'bar', broken: 'wear' }
     *   Object.fromQueryString('foo[]=1&foo[]=2')     -> { foo: ['1','2'] }
     *   Object.fromQueryString('foo=true', true)      -> { foo: true }
     *
     ***/
    'fromQueryString': function(str, castBoolean) {
      var result = object.extended(), split;
      str = str && str.toString ? str.toString() : '';
      str.replace(/^.*?\?/, '').split('&').forEach(function(p) {
        var split = p.split('=');
        if(split.length !== 2) return;
        setParamsObject(result, split[0], decodeURIComponent(split[1]), castBoolean);
      });
      return result;
    },

    /***
     * @method Object.toQueryString(<obj>, [namespace] = null)
     * @returns Object
     * @short Converts the object into a query string.
     * @extra Accepts deep nested objects and arrays. If [namespace] is passed, it will be prefixed to all param names.
     * @example
     *
     *   Object.toQueryString({foo:'bar'})          -> 'foo=bar'
     *   Object.toQueryString({foo:['a','b','c']})  -> 'foo[0]=a&foo[1]=b&foo[2]=c'
     *   Object.toQueryString({name:'Bob'}, 'user') -> 'user[name]=Bob'
     *
     ***/
    'toQueryString': function(obj, namespace) {
      return objectToQueryString(namespace, obj);
    },

    /***
     * @method tap(<obj>, <fn>)
     * @returns Object
     * @short Runs <fn> and returns <obj>.
     * @extra  A string can also be used as a shortcut to a method. This method is used to run an intermediary function in the middle of method chaining. As a standalone method on the Object class it doesn't have too much use. The power of %tap% comes when using extended objects or modifying the Object prototype with Object.extend().
     * @example
     *
     *   Object.extend();
     *   [2,4,6].map(Math.exp).tap(function(arr) {
     *     arr.pop()
     *   });
     *   [2,4,6].map(Math.exp).tap('pop').map(Math.round); ->  [7,55]
     *
     ***/
    'tap': function(obj, arg) {
      var fn = arg;
      if(!isFunction(arg)) {
        fn = function() {
          if(arg) obj[arg]();
        }
      }
      fn.call(obj, obj);
      return obj;
    },

    /***
     * @method has(<obj>, <key>)
     * @returns Boolean
     * @short Checks if <obj> has <key> using hasOwnProperty from Object.prototype.
     * @extra This method is considered safer than %Object#hasOwnProperty% when using objects as hashes. See http://www.devthought.com/2012/01/18/an-object-is-not-a-hash/ for more.
     * @example
     *
     *   Object.has({ foo: 'bar' }, 'foo') -> true
     *   Object.has({ foo: 'bar' }, 'baz') -> false
     *   Object.has({ hasOwnProperty: true }, 'foo') -> false
     *
     ***/
    'has': function (obj, key) {
      return hasOwnProperty(obj, key);
    },

    /***
     * @method select(<obj>, <find>, ...)
     * @returns Object
     * @short Builds a new object containing the values specified in <find>.
     * @extra When <find> is a string, that single key will be selected. It can also be a regex, selecting any key that matches, or an object which will match if the key also exists in that object, effectively doing an "intersect" operation on that object. Multiple selections may also be passed as an array or directly as enumerated arguments. %select% is available as an instance method on extended objects.
     * @example
     *
     *   Object.select({a:1,b:2}, 'a')        -> {a:1}
     *   Object.select({a:1,b:2}, /[a-z]/)    -> {a:1,ba:2}
     *   Object.select({a:1,b:2}, {a:1})      -> {a:1}
     *   Object.select({a:1,b:2}, 'a', 'b')   -> {a:1,b:2}
     *   Object.select({a:1,b:2}, ['a', 'b']) -> {a:1,b:2}
     *
     ***/
    'select': function (obj) {
      return selectFromObject(obj, arguments, true);
    },

    /***
     * @method reject(<obj>, <find>, ...)
     * @returns Object
     * @short Builds a new object containing all values except those specified in <find>.
     * @extra When <find> is a string, that single key will be rejected. It can also be a regex, rejecting any key that matches, or an object which will match if the key also exists in that object, effectively "subtracting" that object. Multiple selections may also be passed as an array or directly as enumerated arguments. %reject% is available as an instance method on extended objects.
     * @example
     *
     *   Object.reject({a:1,b:2}, 'a')        -> {b:2}
     *   Object.reject({a:1,b:2}, /[a-z]/)    -> {}
     *   Object.reject({a:1,b:2}, {a:1})      -> {b:2}
     *   Object.reject({a:1,b:2}, 'a', 'b')   -> {}
     *   Object.reject({a:1,b:2}, ['a', 'b']) -> {}
     *
     ***/
    'reject': function (obj) {
      return selectFromObject(obj, arguments, false);
    }

  });


  buildTypeMethods();
  buildObjectExtend();
  buildObjectInstanceMethods(ObjectHashMethods, Hash);

  /***
   * @package RegExp
   * @dependency core
   * @description Escaping regexes and manipulating their flags.
   *
   * Note here that methods on the RegExp class like .exec and .test will fail in the current version of SpiderMonkey being
   * used by CouchDB when using shorthand regex notation like /foo/. This is the reason for the intermixed use of shorthand
   * and compiled regexes here. If you're using JS in CouchDB, it is safer to ALWAYS compile your regexes from a string.
   *
   ***/

  extend(regexp, false, true, {

   /***
    * @method RegExp.escape(<str> = '')
    * @returns String
    * @short Escapes all RegExp tokens in a string.
    * @example
    *
    *   RegExp.escape('really?')      -> 'really\?'
    *   RegExp.escape('yes.')         -> 'yes\.'
    *   RegExp.escape('(not really)') -> '\(not really\)'
    *
    ***/
    'escape': function(str) {
      return escapeRegExp(str);
    }

  });

  extend(regexp, true, true, {

   /***
    * @method getFlags()
    * @returns String
    * @short Returns the flags of the regex as a string.
    * @example
    *
    *   /texty/gim.getFlags('testy') -> 'gim'
    *
    ***/
    'getFlags': function() {
      return getRegExpFlags(this);
    },

   /***
    * @method setFlags(<flags>)
    * @returns RegExp
    * @short Sets the flags on a regex and retuns a copy.
    * @example
    *
    *   /texty/.setFlags('gim') -> now has global, ignoreCase, and multiline set
    *
    ***/
    'setFlags': function(flags) {
      return regexp(this.source, flags);
    },

   /***
    * @method addFlag(<flag>)
    * @returns RegExp
    * @short Adds <flag> to the regex.
    * @example
    *
    *   /texty/.addFlag('g') -> now has global flag set
    *
    ***/
    'addFlag': function(flag) {
      return this.setFlags(getRegExpFlags(this, flag));
    },

   /***
    * @method removeFlag(<flag>)
    * @returns RegExp
    * @short Removes <flag> from the regex.
    * @example
    *
    *   /texty/g.removeFlag('g') -> now has global flag removed
    *
    ***/
    'removeFlag': function(flag) {
      return this.setFlags(getRegExpFlags(this).replace(flag, ''));
    }

  });



  /***
   * @package String
   * @dependency core
   * @description String manupulation, escaping, encoding, truncation, and:conversion.
   *
   ***/

  function getAcronym(word) {
    var inflector = string.Inflector;
    var word = inflector && inflector.acronyms[word];
    if(isString(word)) {
      return word;
    }
  }

  function checkRepeatRange(num) {
    num = +num;
    if(num < 0 || num === Infinity) {
      throw new RangeError('Invalid number');
    }
    return num;
  }

  function padString(num, padding) {
    return repeatString(isDefined(padding) ? padding : ' ', num);
  }

  function truncateString(str, length, from, ellipsis, split) {
    var str1, str2, len1, len2;
    if(str.length <= length) {
      return str.toString();
    }
    ellipsis = isUndefined(ellipsis) ? '...' : ellipsis;
    switch(from) {
      case 'left':
        str2 = split ? truncateOnWord(str, length, true) : str.slice(str.length - length);
        return ellipsis + str2;
      case 'middle':
        len1 = ceil(length / 2);
        len2 = floor(length / 2);
        str1 = split ? truncateOnWord(str, len1) : str.slice(0, len1);
        str2 = split ? truncateOnWord(str, len2, true) : str.slice(str.length - len2);
        return str1 + ellipsis + str2;
      default:
        str1 = split ? truncateOnWord(str, length) : str.slice(0, length);
        return str1 + ellipsis;
    }
  }

  function truncateOnWord(str, limit, fromLeft) {
    if(fromLeft) {
      return truncateOnWord(str.reverse(), limit).reverse();
    }
    var reg = regexp('(?=[' + getTrimmableCharacters() + '])');
    var words = str.split(reg);
    var count = 0;
    return words.filter(function(word) {
      count += word.length;
      return count <= limit;
    }).join('');
  }

  function numberOrIndex(str, n, from) {
    if(isString(n)) {
      n = str.indexOf(n);
      if(n === -1) {
        n = from ? str.length : 0;
      }
    }
    return n;
  }

  var btoa, atob;

  function buildBase64(key) {
    if(globalContext.btoa) {
      btoa = globalContext.btoa;
      atob = globalContext.atob;
      return;
    }
    var base64reg = /[^A-Za-z0-9\+\/\=]/g;
    btoa = function(str) {
      var output = '';
      var chr1, chr2, chr3;
      var enc1, enc2, enc3, enc4;
      var i = 0;
      do {
        chr1 = str.charCodeAt(i++);
        chr2 = str.charCodeAt(i++);
        chr3 = str.charCodeAt(i++);
        enc1 = chr1 >> 2;
        enc2 = ((chr1 & 3) << 4) | (chr2 >> 4);
        enc3 = ((chr2 & 15) << 2) | (chr3 >> 6);
        enc4 = chr3 & 63;
        if (isNaN(chr2)) {
          enc3 = enc4 = 64;
        } else if (isNaN(chr3)) {
          enc4 = 64;
        }
        output = output + key.charAt(enc1) + key.charAt(enc2) + key.charAt(enc3) + key.charAt(enc4);
        chr1 = chr2 = chr3 = '';
        enc1 = enc2 = enc3 = enc4 = '';
      } while (i < str.length);
      return output;
    }
    atob = function(input) {
      var output = '';
      var chr1, chr2, chr3;
      var enc1, enc2, enc3, enc4;
      var i = 0;
      if(input.match(base64reg)) {
        throw new Error('String contains invalid base64 characters');
      }
      input = input.replace(/[^A-Za-z0-9\+\/\=]/g, '');
      do {
        enc1 = key.indexOf(input.charAt(i++));
        enc2 = key.indexOf(input.charAt(i++));
        enc3 = key.indexOf(input.charAt(i++));
        enc4 = key.indexOf(input.charAt(i++));
        chr1 = (enc1 << 2) | (enc2 >> 4);
        chr2 = ((enc2 & 15) << 4) | (enc3 >> 2);
        chr3 = ((enc3 & 3) << 6) | enc4;
        output = output + chr(chr1);
        if (enc3 != 64) {
          output = output + chr(chr2);
        }
        if (enc4 != 64) {
          output = output + chr(chr3);
        }
        chr1 = chr2 = chr3 = '';
        enc1 = enc2 = enc3 = enc4 = '';
      } while (i < input.length);
      return output;
    }
  }

  extend(string, true, false, {
    /***
     * @method repeat([num] = 0)
     * @returns String
     * @short Returns the string repeated [num] times.
     * @example
     *
     *   'jumpy'.repeat(2) -> 'jumpyjumpy'
     *   'a'.repeat(5)     -> 'aaaaa'
     *   'a'.repeat(0)     -> ''
     *
     ***/
    'repeat': function(num) {
      num = checkRepeatRange(num);
      return repeatString(this, num);
    }

  });

  extend(string, true, function(reg) { return isRegExp(reg) || arguments.length > 2; }, {

    /***
     * @method startsWith(<find>, [pos] = 0, [case] = true)
     * @returns Boolean
     * @short Returns true if the string starts with <find>.
     * @extra <find> may be either a string or regex. Search begins at [pos], which defaults to the entire string. Case sensitive if [case] is true.
     * @example
     *
     *   'hello'.startsWith('hell')           -> true
     *   'hello'.startsWith(/[a-h]/)          -> true
     *   'hello'.startsWith('HELL')           -> false
     *   'hello'.startsWith('ell', 1)         -> true
     *   'hello'.startsWith('HELL', 0, false) -> true
     *
     ***/
    'startsWith': function(reg) {
      var args = arguments, pos = args[1], c = args[2], str = this, source;
      if(pos) str = str.slice(pos);
      if(isUndefined(c)) c = true;
      source = isRegExp(reg) ? reg.source.replace('^', '') : escapeRegExp(reg);
      return regexp('^' + source, c ? '' : 'i').test(str);
    },

    /***
     * @method endsWith(<find>, [pos] = length, [case] = true)
     * @returns Boolean
     * @short Returns true if the string ends with <find>.
     * @extra <find> may be either a string or regex. Search ends at [pos], which defaults to the entire string. Case sensitive if [case] is true.
     * @example
     *
     *   'jumpy'.endsWith('py')            -> true
     *   'jumpy'.endsWith(/[q-z]/)         -> true
     *   'jumpy'.endsWith('MPY')           -> false
     *   'jumpy'.endsWith('mp', 4)         -> false
     *   'jumpy'.endsWith('MPY', 5, false) -> true
     *
     ***/
    'endsWith': function(reg) {
      var args = arguments, pos = args[1], c = args[2], str = this, source;
      if(isDefined(pos)) str = str.slice(0, pos);
      if(isUndefined(c)) c = true;
      source = isRegExp(reg) ? reg.source.replace('$', '') : escapeRegExp(reg);
      return regexp(source + '$', c ? '' : 'i').test(str);
    }

  });

  extend(string, true, true, {

     /***
      * @method escapeRegExp()
      * @returns String
      * @short Escapes all RegExp tokens in the string.
      * @example
      *
      *   'really?'.escapeRegExp()       -> 'really\?'
      *   'yes.'.escapeRegExp()         -> 'yes\.'
      *   '(not really)'.escapeRegExp() -> '\(not really\)'
      *
      ***/
    'escapeRegExp': function() {
      return escapeRegExp(this);
    },

     /***
      * @method escapeURL([param] = false)
      * @returns String
      * @short Escapes characters in a string to make a valid URL.
      * @extra If [param] is true, it will also escape valid URL characters for use as a URL parameter.
      * @example
      *
      *   'http://foo.com/"bar"'.escapeURL()     -> 'http://foo.com/%22bar%22'
      *   'http://foo.com/"bar"'.escapeURL(true) -> 'http%3A%2F%2Ffoo.com%2F%22bar%22'
      *
      ***/
    'escapeURL': function(param) {
      return param ? encodeURIComponent(this) : encodeURI(this);
    },

     /***
      * @method unescapeURL([partial] = false)
      * @returns String
      * @short Restores escaped characters in a URL escaped string.
      * @extra If [partial] is true, it will only unescape non-valid URL characters. [partial] is included here for completeness, but should very rarely be needed.
      * @example
      *
      *   'http%3A%2F%2Ffoo.com%2Fthe%20bar'.unescapeURL()     -> 'http://foo.com/the bar'
      *   'http%3A%2F%2Ffoo.com%2Fthe%20bar'.unescapeURL(true) -> 'http%3A%2F%2Ffoo.com%2Fthe bar'
      *
      ***/
    'unescapeURL': function(param) {
      return param ? decodeURI(this) : decodeURIComponent(this);
    },

     /***
      * @method escapeHTML()
      * @returns String
      * @short Converts HTML characters to their entity equivalents.
      * @example
      *
      *   '<p>some text</p>'.escapeHTML() -> '&lt;p&gt;some text&lt;/p&gt;'
      *   'one & two'.escapeHTML()        -> 'one &amp; two'
      *
      ***/
    'escapeHTML': function() {
      return this.replace(/&/g,  '&amp;' )
                 .replace(/</g,  '&lt;'  )
                 .replace(/>/g,  '&gt;'  )
                 .replace(/"/g,  '&quot;')
                 .replace(/'/g,  '&apos;')
                 .replace(/\//g, '&#x2f;');
    },

     /***
      * @method unescapeHTML([partial] = false)
      * @returns String
      * @short Restores escaped HTML characters.
      * @example
      *
      *   '&lt;p&gt;some text&lt;/p&gt;'.unescapeHTML() -> '<p>some text</p>'
      *   'one &amp; two'.unescapeHTML()                -> 'one & two'
      *
      ***/
    'unescapeHTML': function() {
      return this.replace(/&lt;/g,   '<')
                 .replace(/&gt;/g,   '>')
                 .replace(/&quot;/g, '"')
                 .replace(/&apos;/g, "'")
                 .replace(/&#x2f;/g, '/')
                 .replace(/&amp;/g,  '&');
    },

     /***
      * @method encodeBase64()
      * @returns String
      * @short Encodes the string into base64 encoding.
      * @extra This method wraps the browser native %btoa% when available, and uses a custom implementation when not available. It can also handle Unicode string encodings.
      * @example
      *
      *   'gonna get encoded!'.encodeBase64()  -> 'Z29ubmEgZ2V0IGVuY29kZWQh'
      *   'http://twitter.com/'.encodeBase64() -> 'aHR0cDovL3R3aXR0ZXIuY29tLw=='
      *
      ***/
    'encodeBase64': function() {
      return btoa(unescape(encodeURIComponent(this)));
    },

     /***
      * @method decodeBase64()
      * @returns String
      * @short Decodes the string from base64 encoding.
      * @extra This method wraps the browser native %atob% when available, and uses a custom implementation when not available. It can also handle Unicode string encodings.
      * @example
      *
      *   'aHR0cDovL3R3aXR0ZXIuY29tLw=='.decodeBase64() -> 'http://twitter.com/'
      *   'anVzdCBnb3QgZGVjb2RlZA=='.decodeBase64()     -> 'just got decoded!'
      *
      ***/
    'decodeBase64': function() {
      return decodeURIComponent(escape(atob(this)));
    },

    /***
     * @method each([search] = single character, [fn])
     * @returns Array
     * @short Runs callback [fn] against each occurence of [search].
     * @extra Returns an array of matches. [search] may be either a string or regex, and defaults to every character in the string.
     * @example
     *
     *   'jumpy'.each() -> ['j','u','m','p','y']
     *   'jumpy'.each(/[r-z]/) -> ['u','y']
     *   'jumpy'.each(/[r-z]/, function(m) {
     *     // Called twice: "u", "y"
     *   });
     *
     ***/
    'each': function(search, fn) {
      var match, i, len;
      if(isFunction(search)) {
        fn = search;
        search = /[\s\S]/g;
      } else if(!search) {
        search = /[\s\S]/g
      } else if(isString(search)) {
        search = regexp(escapeRegExp(search), 'gi');
      } else if(isRegExp(search)) {
        search = regexp(search.source, getRegExpFlags(search, 'g'));
      }
      match = this.match(search) || [];
      if(fn) {
        for(i = 0, len = match.length; i < len; i++) {
          match[i] = fn.call(this, match[i], i, match) || match[i];
        }
      }
      return match;
    },

    /***
     * @method shift(<n>)
     * @returns Array
     * @short Shifts each character in the string <n> places in the character map.
     * @example
     *
     *   'a'.shift(1)  -> 'b'
     *   'ク'.shift(1) -> 'グ'
     *
     ***/
    'shift': function(n) {
      var result = '';
      n = n || 0;
      this.codes(function(c) {
        result += chr(c + n);
      });
      return result;
    },

    /***
     * @method codes([fn])
     * @returns Array
     * @short Runs callback [fn] against each character code in the string. Returns an array of character codes.
     * @example
     *
     *   'jumpy'.codes() -> [106,117,109,112,121]
     *   'jumpy'.codes(function(c) {
     *     // Called 5 times: 106, 117, 109, 112, 121
     *   });
     *
     ***/
    'codes': function(fn) {
      var codes = [], i, len;
      for(i = 0, len = this.length; i < len; i++) {
        var code = this.charCodeAt(i);
        codes.push(code);
        if(fn) fn.call(this, code, i);
      }
      return codes;
    },

    /***
     * @method chars([fn])
     * @returns Array
     * @short Runs callback [fn] against each character in the string. Returns an array of characters.
     * @example
     *
     *   'jumpy'.chars() -> ['j','u','m','p','y']
     *   'jumpy'.chars(function(c) {
     *     // Called 5 times: "j","u","m","p","y"
     *   });
     *
     ***/
    'chars': function(fn) {
      return this.each(fn);
    },

    /***
     * @method words([fn])
     * @returns Array
     * @short Runs callback [fn] against each word in the string. Returns an array of words.
     * @extra A "word" here is defined as any sequence of non-whitespace characters.
     * @example
     *
     *   'broken wear'.words() -> ['broken','wear']
     *   'broken wear'.words(function(w) {
     *     // Called twice: "broken", "wear"
     *   });
     *
     ***/
    'words': function(fn) {
      return this.trim().each(/\S+/g, fn);
    },

    /***
     * @method lines([fn])
     * @returns Array
     * @short Runs callback [fn] against each line in the string. Returns an array of lines.
     * @example
     *
     *   'broken wear\nand\njumpy jump'.lines() -> ['broken wear','and','jumpy jump']
     *   'broken wear\nand\njumpy jump'.lines(function(l) {
     *     // Called three times: "broken wear", "and", "jumpy jump"
     *   });
     *
     ***/
    'lines': function(fn) {
      return this.trim().each(/^.*$/gm, fn);
    },

    /***
     * @method paragraphs([fn])
     * @returns Array
     * @short Runs callback [fn] against each paragraph in the string. Returns an array of paragraphs.
     * @extra A paragraph here is defined as a block of text bounded by two or more line breaks.
     * @example
     *
     *   'Once upon a time.\n\nIn the land of oz...'.paragraphs() -> ['Once upon a time.','In the land of oz...']
     *   'Once upon a time.\n\nIn the land of oz...'.paragraphs(function(p) {
     *     // Called twice: "Once upon a time.", "In teh land of oz..."
     *   });
     *
     ***/
    'paragraphs': function(fn) {
      var paragraphs = this.trim().split(/[\r\n]{2,}/);
      paragraphs = paragraphs.map(function(p) {
        if(fn) var s = fn.call(p);
        return s ? s : p;
      });
      return paragraphs;
    },

    /***
     * @method isBlank()
     * @returns Boolean
     * @short Returns true if the string has a length of 0 or contains only whitespace.
     * @example
     *
     *   ''.isBlank()      -> true
     *   '   '.isBlank()   -> true
     *   'noway'.isBlank() -> false
     *
     ***/
    'isBlank': function() {
      return this.trim().length === 0;
    },

    /***
     * @method has(<find>)
     * @returns Boolean
     * @short Returns true if the string matches <find>.
     * @extra <find> may be a string or regex.
     * @example
     *
     *   'jumpy'.has('py')     -> true
     *   'broken'.has(/[a-n]/) -> true
     *   'broken'.has(/[s-z]/) -> false
     *
     ***/
    'has': function(find) {
      return this.search(isRegExp(find) ? find : escapeRegExp(find)) !== -1;
    },


    /***
     * @method add(<str>, [index] = length)
     * @returns String
     * @short Adds <str> at [index]. Negative values are also allowed.
     * @extra %insert% is provided as an alias, and is generally more readable when using an index.
     * @example
     *
     *   'schfifty'.add(' five')      -> schfifty five
     *   'dopamine'.insert('e', 3)       -> dopeamine
     *   'spelling eror'.insert('r', -3) -> spelling error
     *
     ***/
    'add': function(str, index) {
      index = isUndefined(index) ? this.length : index;
      return this.slice(0, index) + str + this.slice(index);
    },

    /***
     * @method remove(<f>)
     * @returns String
     * @short Removes any part of the string that matches <f>.
     * @extra <f> can be a string or a regex.
     * @example
     *
     *   'schfifty five'.remove('f')     -> 'schity ive'
     *   'schfifty five'.remove(/[a-f]/g) -> 'shity iv'
     *
     ***/
    'remove': function(f) {
      return this.replace(f, '');
    },

    /***
     * @method reverse()
     * @returns String
     * @short Reverses the string.
     * @example
     *
     *   'jumpy'.reverse()        -> 'ypmuj'
     *   'lucky charms'.reverse() -> 'smrahc ykcul'
     *
     ***/
    'reverse': function() {
      return this.split('').reverse().join('');
    },

    /***
     * @method compact()
     * @returns String
     * @short Compacts all white space in the string to a single space and trims the ends.
     * @example
     *
     *   'too \n much \n space'.compact() -> 'too much space'
     *   'enough \n '.compact()           -> 'enought'
     *
     ***/
    'compact': function() {
      return this.trim().replace(/([\r\n\s　])+/g, function(match, whitespace){
        return whitespace === '　' ? whitespace : ' ';
      });
    },

    /***
     * @method at(<index>, [loop] = true)
     * @returns String or Array
     * @short Gets the character(s) at a given index.
     * @extra When [loop] is true, overshooting the end of the string (or the beginning) will begin counting from the other end. As an alternate syntax, passing multiple indexes will get the characters at those indexes.
     * @example
     *
     *   'jumpy'.at(0)               -> 'j'
     *   'jumpy'.at(2)               -> 'm'
     *   'jumpy'.at(5)               -> 'j'
     *   'jumpy'.at(5, false)        -> ''
     *   'jumpy'.at(-1)              -> 'y'
     *   'lucky charms'.at(2,4,6,8) -> ['u','k','y',c']
     *
     ***/
    'at': function() {
      return getEntriesForIndexes(this, arguments, true);
    },

    /***
     * @method from([index] = 0)
     * @returns String
     * @short Returns a section of the string starting from [index].
     * @example
     *
     *   'lucky charms'.from()   -> 'lucky charms'
     *   'lucky charms'.from(7)  -> 'harms'
     *
     ***/
    'from': function(from) {
      return this.slice(numberOrIndex(this, from, true));
    },

    /***
     * @method to([index] = end)
     * @returns String
     * @short Returns a section of the string ending at [index].
     * @example
     *
     *   'lucky charms'.to()   -> 'lucky charms'
     *   'lucky charms'.to(7)  -> 'lucky ch'
     *
     ***/
    'to': function(to) {
      if(isUndefined(to)) to = this.length;
      return this.slice(0, numberOrIndex(this, to));
    },

    /***
     * @method dasherize()
     * @returns String
     * @short Converts underscores and camel casing to hypens.
     * @example
     *
     *   'a_farewell_to_arms'.dasherize() -> 'a-farewell-to-arms'
     *   'capsLock'.dasherize()           -> 'caps-lock'
     *
     ***/
    'dasherize': function() {
      return this.underscore().replace(/_/g, '-');
    },

    /***
     * @method underscore()
     * @returns String
     * @short Converts hyphens and camel casing to underscores.
     * @example
     *
     *   'a-farewell-to-arms'.underscore() -> 'a_farewell_to_arms'
     *   'capsLock'.underscore()           -> 'caps_lock'
     *
     ***/
    'underscore': function() {
      return this
        .replace(/[-\s]+/g, '_')
        .replace(string.Inflector && string.Inflector.acronymRegExp, function(acronym, index) {
          return (index > 0 ? '_' : '') + acronym.toLowerCase();
        })
        .replace(/([A-Z\d]+)([A-Z][a-z])/g,'$1_$2')
        .replace(/([a-z\d])([A-Z])/g,'$1_$2')
        .toLowerCase();
    },

    /***
     * @method camelize([first] = true)
     * @returns String
     * @short Converts underscores and hyphens to camel case. If [first] is true the first letter will also be capitalized.
     * @extra If the Inflections package is included acryonyms can also be defined that will be used when camelizing.
     * @example
     *
     *   'caps_lock'.camelize()              -> 'CapsLock'
     *   'moz-border-radius'.camelize()      -> 'MozBorderRadius'
     *   'moz-border-radius'.camelize(false) -> 'mozBorderRadius'
     *
     ***/
    'camelize': function(first) {
      return this.underscore().replace(/(^|_)([^_]+)/g, function(match, pre, word, index) {
        var acronym = getAcronym(word), capitalize = first !== false || index > 0;
        if(acronym) return capitalize ? acronym : acronym.toLowerCase();
        return capitalize ? word.capitalize() : word;
      });
    },

    /***
     * @method spacify()
     * @returns String
     * @short Converts camel case, underscores, and hyphens to a properly spaced string.
     * @example
     *
     *   'camelCase'.spacify()                         -> 'camel case'
     *   'an-ugly-string'.spacify()                    -> 'an ugly string'
     *   'oh-no_youDid-not'.spacify().capitalize(true) -> 'something else'
     *
     ***/
    'spacify': function() {
      return this.underscore().replace(/_/g, ' ');
    },

    /***
     * @method stripTags([tag1], [tag2], ...)
     * @returns String
     * @short Strips all HTML tags from the string.
     * @extra Tags to strip may be enumerated in the parameters, otherwise will strip all.
     * @example
     *
     *   '<p>just <b>some</b> text</p>'.stripTags()    -> 'just some text'
     *   '<p>just <b>some</b> text</p>'.stripTags('p') -> 'just <b>some</b> text'
     *
     ***/
    'stripTags': function() {
      var str = this, args = arguments.length > 0 ? arguments : [''];
      flattenedArgs(args, function(tag) {
        str = str.replace(regexp('<\/?' + escapeRegExp(tag) + '[^<>]*>', 'gi'), '');
      });
      return str;
    },

    /***
     * @method removeTags([tag1], [tag2], ...)
     * @returns String
     * @short Removes all HTML tags and their contents from the string.
     * @extra Tags to remove may be enumerated in the parameters, otherwise will remove all.
     * @example
     *
     *   '<p>just <b>some</b> text</p>'.removeTags()    -> ''
     *   '<p>just <b>some</b> text</p>'.removeTags('b') -> '<p>just text</p>'
     *
     ***/
    'removeTags': function() {
      var str = this, args = arguments.length > 0 ? arguments : ['\\S+'];
      flattenedArgs(args, function(t) {
        var reg = regexp('<(' + t + ')[^<>]*(?:\\/>|>.*?<\\/\\1>)', 'gi');
        str = str.replace(reg, '');
      });
      return str;
    },

    /***
     * @method truncate(<length>, [from] = 'right', [ellipsis] = '...')
     * @returns String
     * @short Truncates a string.
     * @extra [from] can be %'right'%, %'left'%, or %'middle'%. If the string is shorter than <length>, [ellipsis] will not be added.
     * @example
     *
     *   'sittin on the dock of the bay'.truncate(18)           -> 'just sittin on the do...'
     *   'sittin on the dock of the bay'.truncate(18, 'left')   -> '...the dock of the bay'
     *   'sittin on the dock of the bay'.truncate(18, 'middle') -> 'just sitt...of the bay'
     *
     ***/
    'truncate': function(length, from, ellipsis) {
      return truncateString(this, length, from, ellipsis);
    },

    /***
     * @method truncateOnWord(<length>, [from] = 'right', [ellipsis] = '...')
     * @returns String
     * @short Truncates a string without splitting up words.
     * @extra [from] can be %'right'%, %'left'%, or %'middle'%. If the string is shorter than <length>, [ellipsis] will not be added.
     * @example
     *
     *   'here we go'.truncateOnWord(5)               -> 'here...'
     *   'here we go'.truncateOnWord(5, 'left')       -> '...we go'
     *
     ***/
    'truncateOnWord': function(length, from, ellipsis) {
      return truncateString(this, length, from, ellipsis, true);
    },

    /***
     * @method pad[Side](<num> = null, [padding] = ' ')
     * @returns String
     * @short Pads the string out with [padding] to be exactly <num> characters.
     *
     * @set
     *   pad
     *   padLeft
     *   padRight
     *
     * @example
     *
     *   'wasabi'.pad(8)           -> ' wasabi '
     *   'wasabi'.padLeft(8)       -> '  wasabi'
     *   'wasabi'.padRight(8)      -> 'wasabi  '
     *   'wasabi'.padRight(8, '-') -> 'wasabi--'
     *
     ***/
    'pad': function(num, padding) {
      var half, front, back;
      num   = checkRepeatRange(num);
      half  = max(0, num - this.length) / 2;
      front = floor(half);
      back  = ceil(half);
      return padString(front, padding) + this + padString(back, padding);
    },

    'padLeft': function(num, padding) {
      num = checkRepeatRange(num);
      return padString(max(0, num - this.length), padding) + this;
    },

    'padRight': function(num, padding) {
      num = checkRepeatRange(num);
      return this + padString(max(0, num - this.length), padding);
    },

    /***
     * @method first([n] = 1)
     * @returns String
     * @short Returns the first [n] characters of the string.
     * @example
     *
     *   'lucky charms'.first()   -> 'l'
     *   'lucky charms'.first(3)  -> 'luc'
     *
     ***/
    'first': function(num) {
      if(isUndefined(num)) num = 1;
      return this.substr(0, num);
    },

    /***
     * @method last([n] = 1)
     * @returns String
     * @short Returns the last [n] characters of the string.
     * @example
     *
     *   'lucky charms'.last()   -> 's'
     *   'lucky charms'.last(3)  -> 'rms'
     *
     ***/
    'last': function(num) {
      if(isUndefined(num)) num = 1;
      var start = this.length - num < 0 ? 0 : this.length - num;
      return this.substr(start);
    },

    /***
     * @method toNumber([base] = 10)
     * @returns Number
     * @short Converts the string into a number.
     * @extra Any value with a "." fill be converted to a floating point value, otherwise an integer.
     * @example
     *
     *   '153'.toNumber()    -> 153
     *   '12,000'.toNumber() -> 12000
     *   '10px'.toNumber()   -> 10
     *   'ff'.toNumber(16)   -> 255
     *
     ***/
    'toNumber': function(base) {
      return stringToNumber(this, base);
    },

    /***
     * @method capitalize([all] = false)
     * @returns String
     * @short Capitalizes the first character in the string and downcases all other letters.
     * @extra If [all] is true, all words in the string will be capitalized.
     * @example
     *
     *   'hello'.capitalize()           -> 'Hello'
     *   'hello kitty'.capitalize()     -> 'Hello kitty'
     *   'hello kitty'.capitalize(true) -> 'Hello Kitty'
     *
     *
     ***/
    'capitalize': function(all) {
      var lastResponded;
      return this.toLowerCase().replace(all ? /[^']/g : /^\S/, function(lower) {
        var upper = lower.toUpperCase(), result;
        result = lastResponded ? lower : upper;
        lastResponded = upper !== lower;
        return result;
      });
    },

    /***
     * @method assign(<obj1>, <obj2>, ...)
     * @returns String
     * @short Assigns variables to tokens in a string, demarcated with `{}`.
     * @extra If an object is passed, it's properties can be assigned using the object's keys (i.e. {name}). If a non-object (string, number, etc.) is passed it can be accessed by the argument number beginning with {1} (as with regex tokens). Multiple objects can be passed and will be merged together (original objects are unaffected).
     * @example
     *
     *   'Welcome, Mr. {name}.'.assign({ name: 'Franklin' })   -> 'Welcome, Mr. Franklin.'
     *   'You are {1} years old today.'.assign(14)             -> 'You are 14 years old today.'
     *   '{n} and {r}'.assign({ n: 'Cheech' }, { r: 'Chong' }) -> 'Cheech and Chong'
     *
     ***/
    'assign': function() {
      var assign = {};
      flattenedArgs(arguments, function(a, i) {
        if(isObjectType(a)) {
          simpleMerge(assign, a);
        } else {
          assign[i + 1] = a;
        }
      });
      return this.replace(/\{([^{]+?)\}/g, function(m, key) {
        return hasOwnProperty(assign, key) ? assign[key] : m;
      });
    }

  });


  // Aliases

  extend(string, true, true, {

    /***
     * @method insert()
     * @alias add
     *
     ***/
    'insert': string.prototype.add
  });

  buildBase64('ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=');

})();

class Queue {
	_items: any[] = [];

	constructor() {
		this._items = [];
	}
	enqueue(item: any) {
		this._items.push(item);
	}
	dequeue() {
		return this._items.shift();
	}
	get size() {
		return this._items.length;
	}
}

export class AutoQueue extends Queue {
	_pendingPromise: boolean;

	constructor() {
		super();
		this._pendingPromise = false;
	}

	enqueue(action: any): Promise<boolean> {
		return new Promise((resolve, reject) => {
			super.enqueue({ action, resolve, reject });
			this.dequeue();
		});
	}

	async dequeue(): Promise<boolean> {
		if (this._pendingPromise) return false;

		let item = super.dequeue();
		if (!item) return false;

		if (this.size > 0) return this.dequeue();

		try {
			this._pendingPromise = true;

			let payload = await item.action(this);

			this._pendingPromise = false;
			item.resolve(payload);
		} catch (e) {
			this._pendingPromise = false;
			item.reject(e);
		} finally {
			this.dequeue();
		}

		return true;
	}
}
